// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

enum ContentTab: String, Hashable {
    case track, goals, history
}

struct ContentView: View {
    @AppStorage("tab") var tab = ContentTab.track

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                TrackView()
                    .navigationTitle("Track")
            }
            .tabItem { Label("Track", systemImage: "square.grid.2x2.fill") }
            .tag(ContentTab.track)

            NavigationStack {
                GoalsView()
                    .navigationTitle("Goals")
            }
            .tabItem { Label("Goals", systemImage: "carrot.fill") }
            .tag(ContentTab.goals)

            NavigationStack {
                HistoryView()
                    .navigationTitle("History")
            }
            .tabItem { Label("History", systemImage: "chart.bar.fill") }
            .tag(ContentTab.history)
        }
    }
}

// MARK: - Track View
struct TrackView: View {
    @State var trackables: [Trackable] = []
    @State var todayCounts: [Int64: Int] = [:]  // trackableId -> count
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        Group {
            if trackables.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(trackables) { trackable in
                            TrackableGridItem(
                                trackable: trackable,
                                count: todayCounts[trackable.id] ?? 0,
                                onTap: {
                                    incrementCount(for: trackable)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }
    
    func refreshData() {
        trackables = BackendService.shared.getAllTrackables()
        let today = BackendService.shared.todayString()
        var counts: [Int64: Int] = [:]
        for trackable in trackables {
            if let count = BackendService.shared.getCount(trackableId: trackable.id, date: today) {
                counts[trackable.id] = count.count
            } else {
                counts[trackable.id] = 0
            }
        }
        todayCounts = counts
    }
    
    func incrementCount(for trackable: Trackable) {
        let today = BackendService.shared.todayString()
        if let newCount = BackendService.shared.incrementCount(trackableId: trackable.id, date: today) {
            todayCounts[trackable.id] = newCount.count
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
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
            
            Image(systemName: "carrot.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
            
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
struct HistoryView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text("Your History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("View your tracking history and progress over time")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}
