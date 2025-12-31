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
                        .renderingMode(.template)
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
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .tag(ContentTab.history)
        }
    }
}
