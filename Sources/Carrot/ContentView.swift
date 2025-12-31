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

struct TrackView: View {
    var body: some View {
        VStack {
            Text("Track your habits here")
                .foregroundStyle(.secondary)
        }
    }
}

struct GoalsView: View {
    var body: some View {
        VStack {
            Text("Manage your goals and habits here")
                .foregroundStyle(.secondary)
        }
    }
}

struct HistoryView: View {
    var body: some View {
        VStack {
            Text("View your history here")
                .foregroundStyle(.secondary)
        }
    }
}
