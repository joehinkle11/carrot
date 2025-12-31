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
    var body: some View {
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
                .foregroundStyle(.tertiary)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Goals View
struct GoalsView: View {
    var body: some View {
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // TODO: Add new trackable
                } label: {
                    Image(systemName: "plus")
                }
            }
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
