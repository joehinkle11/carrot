// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import SkipSQLPlus

/// SQLite database implementation using SkipSQL
class SQLDatabase: DatabaseProtocol {
    private let db: SQLContext
    
    init() throws {
        // Get the app's application support directory for the database file
        // Using URL.applicationSupportDirectory which works on both iOS and Android
        let supportDir = URL.applicationSupportDirectory
        let dbPath = supportDir.appendingPathComponent("carrot.db").path
        
        // Ensure directory exists
        try FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        
        // Open or create the database using SQLPlus for consistent SQLite version across platforms
        db = try SQLContext(path: dbPath, flags: [.create, .readWrite], configuration: .plus)
        
        // Create tables if they don't exist
        try createTables()
        
        // Run migrations for existing databases
        try migrateDatabase()
    }
    
    private func createTables() throws {
        // Create trackables table with color and order columns
        try db.exec(sql: """
            CREATE TABLE IF NOT EXISTS trackables (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                color TEXT NOT NULL DEFAULT '#FF9500',
                sort_order INTEGER NOT NULL DEFAULT -1
            )
        """)
        
        // Create counts table
        try db.exec(sql: """
            CREATE TABLE IF NOT EXISTS counts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date TEXT NOT NULL,
                trackable_id INTEGER NOT NULL,
                count INTEGER NOT NULL DEFAULT 0,
                FOREIGN KEY (trackable_id) REFERENCES trackables(id) ON DELETE CASCADE,
                UNIQUE(date, trackable_id)
            )
        """)
    }
    
    private func migrateDatabase() throws {
        // Check if color column exists in trackables
        let columns = try db.selectAll(sql: "PRAGMA table_info(trackables)")
        let columnNames = columns.compactMap { $0[1].textValue }
        
        // Add color column if it doesn't exist
        if !columnNames.contains("color") {
            try db.exec(sql: "ALTER TABLE trackables ADD COLUMN color TEXT NOT NULL DEFAULT '#FF9500'")
        }
        
        // Add sort_order column if it doesn't exist
        if !columnNames.contains("sort_order") {
            try db.exec(sql: "ALTER TABLE trackables ADD COLUMN sort_order INTEGER NOT NULL DEFAULT -1")
        }
    }
    
    // MARK: - Trackables
    
    func getAllTrackables() throws -> [Trackable] {
        // Order by sort_order first, then by id for stable sorting
        let rows = try db.selectAll(sql: "SELECT id, name, color, sort_order FROM trackables ORDER BY sort_order ASC, id ASC")
        return rows.map { row in
            Trackable(
                id: row[0].integerValue ?? 0,
                name: row[1].textValue ?? "",
                color: row[2].textValue ?? defaultTrackableColor,
                order: Int(row[3].integerValue ?? -1)
            )
        }
    }
    
    func createTrackable(name: String, color: String, order: Int) throws -> Trackable {
        try db.exec(sql: "INSERT INTO trackables (name, color, sort_order) VALUES (?, ?, ?)", 
                   parameters: [.text(name), .text(color), .integer(Int64(order))])
        let id = db.lastInsertRowID
        return Trackable(id: id, name: name, color: color, order: order)
    }
    
    func updateTrackable(_ trackable: Trackable) throws {
        try db.exec(sql: "UPDATE trackables SET name = ?, color = ?, sort_order = ? WHERE id = ?", 
                   parameters: [.text(trackable.name), .text(trackable.color), .integer(Int64(trackable.order)), .integer(trackable.id)])
        if db.changes == 0 {
            throw DatabaseError.notFound
        }
    }
    
    func updateTrackableOrders(_ updates: [(id: Int64, order: Int)]) throws {
        for update in updates {
            try db.exec(sql: "UPDATE trackables SET sort_order = ? WHERE id = ?",
                       parameters: [.integer(Int64(update.order)), .integer(update.id)])
        }
    }
    
    func deleteTrackable(id: Int64) throws {
        // First delete associated counts
        try db.exec(sql: "DELETE FROM counts WHERE trackable_id = ?", parameters: [.integer(id)])
        // Then delete the trackable
        try db.exec(sql: "DELETE FROM trackables WHERE id = ?", parameters: [.integer(id)])
        if db.changes == 0 {
            throw DatabaseError.notFound
        }
    }
    
    // MARK: - Counts
    
    func getCount(trackableId: Int64, date: String) throws -> Count? {
        let rows = try db.selectAll(
            sql: "SELECT id, date, trackable_id, count FROM counts WHERE trackable_id = ? AND date = ?",
            parameters: [.integer(trackableId), .text(date)]
        )
        guard let row = rows.first else { return nil }
        return Count(
            id: row[0].integerValue ?? 0,
            date: row[1].textValue ?? "",
            trackableId: row[2].integerValue ?? 0,
            count: Int(row[3].integerValue ?? 0)
        )
    }
    
    func getAllCounts(trackableId: Int64) throws -> [Count] {
        let rows = try db.selectAll(
            sql: "SELECT id, date, trackable_id, count FROM counts WHERE trackable_id = ? ORDER BY date DESC",
            parameters: [.integer(trackableId)]
        )
        return rows.map { row in
            Count(
                id: row[0].integerValue ?? 0,
                date: row[1].textValue ?? "",
                trackableId: row[2].integerValue ?? 0,
                count: Int(row[3].integerValue ?? 0)
            )
        }
    }
    
    func incrementCount(trackableId: Int64, date: String) throws -> Count {
        // Try to get existing count
        if let existing = try getCount(trackableId: trackableId, date: date) {
            let newCount = existing.count + 1
            try db.exec(
                sql: "UPDATE counts SET count = ? WHERE id = ?",
                parameters: [.integer(Int64(newCount)), .integer(existing.id)]
            )
            return Count(id: existing.id, date: date, trackableId: trackableId, count: newCount)
        } else {
            // Create new count
            try db.exec(
                sql: "INSERT INTO counts (date, trackable_id, count) VALUES (?, ?, ?)",
                parameters: [.text(date), .integer(trackableId), .integer(1)]
            )
            let id = db.lastInsertRowID
            return Count(id: id, date: date, trackableId: trackableId, count: 1)
        }
    }
    
    func decrementCount(trackableId: Int64, date: String) throws -> Count {
        // Try to get existing count
        if let existing = try getCount(trackableId: trackableId, date: date) {
            let newCount = max(0, existing.count - 1)
            try db.exec(
                sql: "UPDATE counts SET count = ? WHERE id = ?",
                parameters: [.integer(Int64(newCount)), .integer(existing.id)]
            )
            return Count(id: existing.id, date: date, trackableId: trackableId, count: newCount)
        } else {
            // No existing count, return 0
            try db.exec(
                sql: "INSERT INTO counts (date, trackable_id, count) VALUES (?, ?, ?)",
                parameters: [.text(date), .integer(trackableId), .integer(0)]
            )
            let id = db.lastInsertRowID
            return Count(id: id, date: date, trackableId: trackableId, count: 0)
        }
    }
    
    func setCount(trackableId: Int64, date: String, count: Int) throws -> Count {
        // Try to get existing count
        if let existing = try getCount(trackableId: trackableId, date: date) {
            try db.exec(
                sql: "UPDATE counts SET count = ? WHERE id = ?",
                parameters: [.integer(Int64(count)), .integer(existing.id)]
            )
            return Count(id: existing.id, date: date, trackableId: trackableId, count: count)
        } else {
            // Create new count
            try db.exec(
                sql: "INSERT INTO counts (date, trackable_id, count) VALUES (?, ?, ?)",
                parameters: [.text(date), .integer(trackableId), .integer(Int64(count))]
            )
            let id = db.lastInsertRowID
            return Count(id: id, date: date, trackableId: trackableId, count: count)
        }
    }
}
