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
    
    var body: some View {
        Group {
            if trackables.isEmpty {
                emptyStateView
            } else {
                Text("\(trackables.count) trackables loaded")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            trackables = BackendService.shared.getAllTrackables()
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

// MARK: - Goals View
struct GoalsView: View {
    @State var trackables: [Trackable] = []
    @State var showingAddAlert = false
    @State var newTrackableName = ""
    
    var body: some View {
        Group {
            if trackables.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(trackables) { trackable in
                        Text(trackable.name)
                    }
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
        .task {
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
