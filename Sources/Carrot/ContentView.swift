// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

enum ContentTab: String, Hashable {
    case track, goals, history
}

enum Constants {
    #if os(iOS)
    static let minusCircleFill = "minus.circle.fill"
    static let advancedToggleIcon = "plusminus.circle"
    static let advancedToggleIconFill = "plusminus.circle.fill"
    #else
    static let minusCircleFill = "arrowtriangle.down.fill"
    static let advancedToggleIcon = "info.circle"
    static let advancedToggleIconFill = "info.circle.fill"
    #endif
}

struct ContentView: View {
    @AppStorage("tab") var tab = ContentTab.track

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                TrackView()
                    .navigationTitle("Track")
            }
            .tabItem {
                Label {
                    Text("Track")
                } icon: {
                    Image("grid", bundle: .module)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .tag(ContentTab.track)

            NavigationStack {
                GoalsView()
                    .navigationTitle("Goals")
            }
            .tabItem {
                Label {
                    Text("Goals")
                } icon: {
                    Image("carrotsmall", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            .tag(ContentTab.goals)

            NavigationStack {
                HistoryView()
                    .navigationTitle("History")
            }
            .tabItem {
                Label {
                    Text("History")
                } icon: {
                    Image("chart", bundle: .module)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .tag(ContentTab.history)
        }
    }
}

// MARK: - Track View
struct TrackView: View {
    @State var trackables: [Trackable] = []
    @State var dayCounts: [Int64: Int] = [:]  // trackableId -> count
    @State var selectedDate: Date = Date()
    @State var isAdvancedMode: Bool = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Date navigation header
            HStack {
                Button {
                    goToPreviousDay()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                        .frame(width: 44, height: 44)
                }
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(formattedDate)
                        .font(.headline)
                    if isToday {
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    goToNextDay()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(isToday ? Color.secondary : Color.orange)
                        .frame(width: 44, height: 44)
                }
                .disabled(isToday)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.05))
            
            // Content
            Group {
                if trackables.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(trackables) { trackable in
                                if isAdvancedMode {
                                    AdvancedTrackableGridItem(
                                        trackable: trackable,
                                        count: dayCounts[trackable.id] ?? 0,
                                        onIncrement: {
                                            incrementCount(for: trackable)
                                        },
                                        onDecrement: {
                                            decrementCount(for: trackable)
                                        }
                                    )
                                } else {
                                    TrackableGridItem(
                                        trackable: trackable,
                                        count: dayCounts[trackable.id] ?? 0,
                                        onTap: {
                                            incrementCount(for: trackable)
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAdvancedMode.toggle()
                } label: {
                    Image(systemName: isAdvancedMode ? Constants.advancedToggleIconFill : Constants.advancedToggleIcon)
                        .font(.title3)
                        .foregroundStyle(isAdvancedMode ? .orange : .secondary)
                }
            }
        }
    }
    
    func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
            refreshData()
        }
    }
    
    func goToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            if newDate <= Date() {
                selectedDate = newDate
                refreshData()
            }
        }
    }
    
    func refreshData() {
        trackables = BackendService.shared.getAllTrackables()
        let dateString = BackendService.shared.dateString(from: selectedDate)
        var counts: [Int64: Int] = [:]
        for trackable in trackables {
            if let count = BackendService.shared.getCount(trackableId: trackable.id, date: dateString) {
                counts[trackable.id] = count.count
            } else {
                counts[trackable.id] = 0
            }
        }
        dayCounts = counts
    }
    
    func incrementCount(for trackable: Trackable) {
        let dateString = BackendService.shared.dateString(from: selectedDate)
        if let newCount = BackendService.shared.incrementCount(trackableId: trackable.id, date: dateString) {
            dayCounts[trackable.id] = newCount.count
        }
    }
    
    func decrementCount(for trackable: Trackable) {
        let dateString = BackendService.shared.dateString(from: selectedDate)
        if let newCount = BackendService.shared.decrementCount(trackableId: trackable.id, date: dateString) {
            dayCounts[trackable.id] = newCount.count
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("grid", bundle: .module)
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Your Trackables")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap on any habit or goal to log it for today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Text("Add habits in the Goals tab to get started")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 16)
        }
    }
}

struct TrackableGridItem: View {
    let trackable: Trackable
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(trackable.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text("\(count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct AdvancedTrackableGridItem: View {
    let trackable: Trackable
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text(trackable.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.orange)
            
            HStack(spacing: 24) {
                Button(action: onDecrement) {
                    Image(systemName: Constants.minusCircleFill)
                        .font(.title)
                        .foregroundStyle(count > 0 ? .orange : .secondary)
                }
                .disabled(count == 0)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Goals View
struct GoalsView: View {
    @State var trackables: [Trackable] = []
    @State var showingAddAlert = false
    @State var showingRenameAlert = false
    @State var newTrackableName = ""
    @State var trackableToEdit: Trackable? = nil
    
    var body: some View {
        Group {
            if trackables.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(trackables) { trackable in
                        HStack {
                            Text(trackable.name)
                            Spacer()
                            Button {
                                trackableToEdit = trackable
                                newTrackableName = trackable.name
                                showingRenameAlert = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteTrackables)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    newTrackableName = ""
                    showingAddAlert = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("New Goal", isPresented: $showingAddAlert) {
            TextField("Name", text: $newTrackableName)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                addTrackable()
            }
        } message: {
            Text("Enter a name for your new habit or goal")
        }
        .alert("Rename", isPresented: $showingRenameAlert) {
            TextField("Name", text: $newTrackableName)
            Button("Cancel", role: .cancel) {
                trackableToEdit = nil
            }
            Button("Save") {
                renameTrackable()
            }
        } message: {
            Text("Enter a new name")
        }
        .onAppear {
            trackables = BackendService.shared.getAllTrackables()
        }
    }
    
    func addTrackable() {
        let name = newTrackableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        if let _ = BackendService.shared.createTrackable(name: name) {
            trackables = BackendService.shared.getAllTrackables()
        }
    }
    
    func renameTrackable() {
        guard let trackable = trackableToEdit else { return }
        let name = newTrackableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        
        let updated = Trackable(id: trackable.id, name: name)
        if BackendService.shared.updateTrackable(updated) {
            trackables = BackendService.shared.getAllTrackables()
        }
        trackableToEdit = nil
    }
    
    func deleteTrackables(at offsets: IndexSet) {
        for index in offsets {
            let trackable = trackables[index]
            let _ = BackendService.shared.deleteTrackable(id: trackable.id)
        }
        trackables = BackendService.shared.getAllTrackables()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("carrot", bundle: .module)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Goals & Habits")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create habits and goals you want to track daily")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// MARK: - History View

/// Represents a single row in the history table
struct HistoryEntry: Identifiable {
    let id: String  // date string as id
    let date: Date
    let dateString: String  // YYYY-MM-DD
    let day: Int
    let month: String
    let dayOfWeek: String
    let count: Int
}

@MainActor var csvContent = ""

struct HistoryView: View {
    @State var trackables: [Trackable] = []
    @State var selectedTrackable: Trackable? = nil
    @State var historyEntries: [HistoryEntry] = []
    @State var showingExportSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal scrolling trackable buttons
            if !trackables.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(trackables) { trackable in
                            Button {
                                selectedTrackable = trackable
                                loadHistory(for: trackable)
                            } label: {
                                Text(trackable.name)
                                    .font(.subheadline)
                                    .fontWeight(selectedTrackable?.id == trackable.id ? .semibold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedTrackable?.id == trackable.id ? Color.orange : Color.orange.opacity(0.1))
                                    .foregroundStyle(selectedTrackable?.id == trackable.id ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
            }
            
            // Content area
            if let selected = selectedTrackable {
                if historyEntries.isEmpty {
                    emptyHistoryView(for: selected)
                } else {
                    List {
                        ForEach(historyEntries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.dayOfWeek)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(entry.month) \(entry.day)")
                                        .font(.headline)
                                }
                                Spacer()
                                Text("\(entry.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(entry.count > 0 ? .orange : .secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            } else if trackables.isEmpty {
                emptyStateView
            } else {
                selectTrackableView
            }
        }
        .onAppear {
            loadTrackables()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    generateCSV()
                    showingExportSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(selectedTrackable == nil || historyEntries.isEmpty)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            CSVExportSheet(
                trackableName: selectedTrackable?.name ?? "Export"
            )
        }
    }
    
    func generateCSV() {
        guard selectedTrackable != nil else {
            csvContent = ""
            return
        }
        
        var lines: [String] = []
        // Header
        lines.append("Date,Count")
        
        // Data rows
        for entry in historyEntries {
            let row = "\(entry.dateString),\(entry.count)"
            lines.append(row)
        }
        
        csvContent = lines.joined(separator: "\n")
    }
    
    func loadTrackables() {
        trackables = BackendService.shared.getAllTrackables()
        // Auto-select first trackable if available
        if selectedTrackable == nil, let first = trackables.first {
            selectedTrackable = first
            loadHistory(for: first)
        }
    }
    
    func loadHistory(for trackable: Trackable) {
        let counts = BackendService.shared.getAllCounts(trackableId: trackable.id)
        
        // Build a dictionary of date string -> count
        var countsByDate: [String: Int] = [:]
        for count in counts {
            countsByDate[count.date] = count.count
        }
        
        // Generate entries for the last 30 days (including days with 0)
        var entries: [HistoryEntry] = []
        let calendar = Calendar.current
        let today = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dateString = dateFormatter.string(from: date)
            let day = calendar.component(.day, from: date)
            let month = monthFormatter.string(from: date)
            let dayOfWeek = dayOfWeekFormatter.string(from: date)
            let count = countsByDate[dateString] ?? 0
            
            let entry = HistoryEntry(
                id: dateString,
                date: date,
                dateString: dateString,
                day: day,
                month: month,
                dayOfWeek: dayOfWeek,
                count: count
            )
            entries.append(entry)
        }
        
        historyEntries = entries
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("Your History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some habits in the Goals tab to see your history")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private var selectTrackableView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("Select a Trackable")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap on a habit above to see its history")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private func emptyHistoryView(for trackable: Trackable) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "calendar")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking '\(trackable.name)' to see your history here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// MARK: - CSV Export Sheet

struct CSVExportSheet: View {
    let trackableName: String
    @Environment(\.dismiss) var dismiss
    @State var copied = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // CSV content in scrollable text view
                TextEditor(text: .constant(csvContent))
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                .background(Color.secondary.opacity(0.1))
                
                // Copy button at bottom
                Button {
                    copyToClipboard()
                } label: {
                    HStack {
                        Image(systemName: copied ? "checkmark" : "square.and.arrow.up")
                        Text(copied ? "Copied!" : "Copy CSV")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(copied ? Color.green : Color.orange)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("\(trackableName) Export")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func copyToClipboard() {
        UIPasteboard.general.string = csvContent
        
        copied = true
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copied = false
        }
    }
}
