// SPDX-License-Identifier: GPL-2.0-or-later

import Foundation
import SkipSQL

/// SQLite database implementation using SkipSQL
class SQLDatabase: DatabaseProtocol {
    private let db: SQLContext
    
    init() throws {
        // Get the app's documents directory for the database file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documentsPath.appendingPathComponent("carrot.db").path
        
        // Open or create the database
        db = try SQLContext(path: dbPath, flags: [.create, .readWrite], configuration: .platform)
        
        // Create tables if they don't exist
        try createTables()
    }
    
    private func createTables() throws {
        // Create trackables table
        try db.exec(sql: """
            CREATE TABLE IF NOT EXISTS trackables (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL
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
    
    // MARK: - Trackables
    
    func getAllTrackables() throws -> [Trackable] {
        let rows = try db.selectAll(sql: "SELECT id, name FROM trackables ORDER BY id")
        return rows.map { row in
            Trackable(
                id: row[0].integerValue ?? 0,
                name: row[1].textValue ?? ""
            )
        }
    }
    
    func createTrackable(name: String) throws -> Trackable {
        try db.exec(sql: "INSERT INTO trackables (name) VALUES (?)", parameters: [.text(name)])
        let id = db.lastInsertRowID
        return Trackable(id: id, name: name)
    }
    
    func updateTrackable(_ trackable: Trackable) throws {
        try db.exec(sql: "UPDATE trackables SET name = ? WHERE id = ?", 
                   parameters: [.text(trackable.name), .integer(trackable.id)])
        if db.changes == 0 {
            throw DatabaseError.notFound
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
