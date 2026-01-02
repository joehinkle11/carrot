// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

struct TrackView: View {
    @State var trackables: [Trackable] = []
    @State var dayCounts: [Int64: Int] = [:]
    @State var selectedDate: Date = TrackView.defaultSelectedDate()
    @State var isAdvancedMode: Bool = false
    @State var showingSleepConfirmation: Bool = false
    @Environment(\.scenePhase) var scenePhase
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var isLateNightWindow: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 0 && hour < 5
    }
    
    static func defaultSelectedDate() -> Date {
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        if hour >= 0 && hour < 5 {
            return Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        }
        return now
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var isEffectiveToday: Bool {
        if isLateNightWindow {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
                return isToday
            }
            return Calendar.current.isDate(selectedDate, inSameDayAs: yesterday)
        }
        return isToday
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            dateNavigationHeader
            
            Group {
                if trackables.isEmpty {
                    emptyStateView
                } else {
                    trackablesGrid
                }
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Reset to current day when app becomes active
                selectedDate = TrackView.defaultSelectedDate()
                refreshData()
            }
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
    
    private var dateNavigationHeader: some View {
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
                handleNextDayTap()
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
        .alert("Did you already sleep?", isPresented: $showingSleepConfirmation) {
            Button("No, still awake", role: .cancel) { }
            Button("Yes, I slept") {
                forceGoToNextDay()
            }
        } message: {
            Text("It's late night hours. Carrot tracks your habits by waking cycle, not by the clock. If you haven't slept yet, you're probably still logging for yesterday.")
        }
    }
    
    private var trackablesGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(trackables) { trackable in
                    let trackableColor = Color(hex: trackable.color) ?? .orange
                    if isAdvancedMode {
                        AdvancedTrackableGridItem(
                            trackable: trackable,
                            count: dayCounts[trackable.id] ?? 0,
                            color: trackableColor,
                            onIncrement: { incrementCount(for: trackable) },
                            onDecrement: { decrementCount(for: trackable) }
                        )
                    } else {
                        TrackableGridItem(
                            trackable: trackable,
                            count: dayCounts[trackable.id] ?? 0,
                            color: trackableColor,
                            onTap: { incrementCount(for: trackable) }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("grid", bundle: .module)
                .renderingMode(.template)
                .resizable()
                .frame(width: 100, height: 100)
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
    
    private func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
            refreshData()
        }
    }
    
    private func handleNextDayTap() {
        guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else { return }
        guard newDate <= Date() else { return }
        
        if isLateNightWindow && Calendar.current.isDateInToday(newDate) {
            showingSleepConfirmation = true
        } else {
            selectedDate = newDate
            refreshData()
        }
    }
    
    private func forceGoToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            if newDate <= Date() {
                selectedDate = newDate
                refreshData()
            }
        }
    }
    
    private func refreshData() {
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
    
    private func incrementCount(for trackable: Trackable) {
        let dateString = BackendService.shared.dateString(from: selectedDate)
        if let newCount = BackendService.shared.incrementCount(trackableId: trackable.id, date: dateString) {
            dayCounts[trackable.id] = newCount.count
        }
    }
    
    private func decrementCount(for trackable: Trackable) {
        let dateString = BackendService.shared.dateString(from: selectedDate)
        if let newCount = BackendService.shared.decrementCount(trackableId: trackable.id, date: dateString) {
            dayCounts[trackable.id] = newCount.count
        }
    }
}
