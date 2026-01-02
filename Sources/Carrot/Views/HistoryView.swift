// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

@MainActor var csvContent = ""
@MainActor var allCSVContent = ""

struct HistoryView: View {
    @State var trackables: [Trackable] = []
    @State var selectedTrackable: Trackable? = nil
    @State var historyEntries: [HistoryEntry] = []
    @State var showingExportSheet = false
    @State var showingInfoSheet = false
    @State var showingExportAllSheet = false
    @State var showingLocalDataTutorial = false
    @State var showGraph = false
    @State var startDate: Date = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State var endDate: Date = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            if !trackables.isEmpty {
                trackableButtonsScroller
            }
            
            contentArea
        }
        .onAppear {
            loadTrackables()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 16) {
                    graphToggleButton
                    infoButton
                    exportButton
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            CSVExportSheet(
                trackableName: selectedTrackable?.name ?? "Export",
                isExportingAll: false,
                startDate: startDate,
                endDate: endDate,
                onExportAll: {
                    generateAllCSV()
                    showingExportSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showingExportAllSheet = true
                    }
                }
            )
        }
        .sheet(isPresented: $showingExportAllSheet) {
            CSVExportSheet(
                trackableName: "All Categories",
                isExportingAll: true,
                startDate: startDate,
                endDate: endDate,
                onExportAll: nil
            )
        }
        .sheet(isPresented: $showingInfoSheet) {
            AppInfoSheet()
        }
        .alert("Your Data is Local", isPresented: $showingLocalDataTutorial) {
            Button("Got it!") {
                TutorialManager.shared.markHistoryDataTutorialSeen()
            }
        } message: {
            Text("All your tracking data is stored entirely on this device — there are no cloud backups.\n\nTo keep your data safe, export to CSV regularly. You can then import it into Google Sheets, Excel, or any spreadsheet app for safekeeping.")
        }
    }
    
    private var trackableButtonsScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(trackables) { trackable in
                    let trackableColor = Color(hex: trackable.color) ?? .orange
                    Button {
                        selectedTrackable = trackable
                        loadHistory(for: trackable)
                    } label: {
                        Text(trackable.name)
                            .font(.subheadline)
                            .fontWeight(selectedTrackable?.id == trackable.id ? .semibold : .regular)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTrackable?.id == trackable.id ? trackableColor : trackableColor.opacity(0.1))
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
    
    @ViewBuilder
    private var contentArea: some View {
        if let selected = selectedTrackable {
            dateRangeSelector(for: selected)
            
            if showGraph {
                graphContentView(for: selected)
            } else if historyEntries.isEmpty {
                emptyHistoryView(for: selected)
            } else {
                historyList
            }
        } else if trackables.isEmpty {
            emptyStateView
        } else {
            selectTrackableView
        }
    }
    
    private var historyList: some View {
        let trackableColor = selectedTrackable.map { Color(hex: $0.color) ?? .orange } ?? .orange
        return List {
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
                        .foregroundStyle(entry.count > 0 ? trackableColor : .secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }
    
    private var graphToggleButton: some View {
        Button {
            showGraph.toggle()
        } label: {
            #if os(iOS)
            Image(systemName: showGraph ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                .foregroundStyle(showGraph ? .orange : .secondary)
            #else
            Text(showGraph ? "Show List" : "Show Graph")
                .foregroundStyle(.orange)
            #endif
        }
    }
    
    private var infoButton: some View {
        Button {
            showingInfoSheet = true
        } label: {
            Image(systemName: "info.circle")
        }
    }
    
    private var exportButton: some View {
        Button {
            generateCSV()
            showingExportSheet = true
        } label: {
            Image(systemName: "square.and.arrow.up")
        }
        .disabled(selectedTrackable == nil || historyEntries.isEmpty)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("chart", bundle: .module)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
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
    
    private func dateRangeSelector(for trackable: Trackable) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Start")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .onChange(of: startDate) { _, _ in
                        if startDate > endDate {
                            startDate = endDate
                        }
                        loadHistory(for: trackable)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("End")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .onChange(of: endDate) { _, _ in
                        if endDate < startDate {
                            endDate = startDate
                        }
                        loadHistory(for: trackable)
                    }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.05))
    }
    
    private func graphContentView(for trackable: Trackable) -> some View {
        let trackableColor = Color(hex: trackable.color) ?? .orange
        return ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(trackable.name)
                        .font(.headline)
                    
                    if chartDataPoints.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("No data in selected range")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    } else {
                        LineChartView(dataPoints: chartDataPoints, lineColor: trackableColor)
                            .frame(height: 220)
                    }
                }
                .padding()
                .background(trackableColor.opacity(0.05))
                .cornerRadius(12)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Summary")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack(spacing: 24) {
                        StatBox(title: "Total", value: "\(totalCount)", color: trackableColor)
                        StatBox(title: "Average", value: String(format: "%.1f", averageCount), color: trackableColor)
                        StatBox(title: "Max", value: "\(maxCount)", color: trackableColor)
                    }
                }
                .padding()
                .background(trackableColor.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
    }
    
    private var chartDataPoints: [ChartDataPoint] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        return historyEntries.map { entry in
            ChartDataPoint(
                id: entry.id,
                date: entry.date,
                value: Double(entry.count),
                label: dateFormatter.string(from: entry.date)
            )
        }
    }
    
    private var totalCount: Int {
        historyEntries.reduce(0) { $0 + $1.count }
    }
    
    private var averageCount: Double {
        guard !historyEntries.isEmpty else { return 0 }
        return Double(totalCount) / Double(historyEntries.count)
    }
    
    private var maxCount: Int {
        historyEntries.map { $0.count }.max() ?? 0
    }
    
    private func loadTrackables() {
        trackables = BackendService.shared.getAllTrackables()
        if selectedTrackable == nil, let first = trackables.first {
            selectedTrackable = first
            loadHistory(for: first)
        }
    }
    
    private func loadHistory(for trackable: Trackable) {
        let counts = BackendService.shared.getAllCounts(trackableId: trackable.id)
        
        var countsByDate: [String: Int] = [:]
        for count in counts {
            countsByDate[count.date] = count.count
        }
        
        var entries: [HistoryEntry] = []
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfEndDate = calendar.startOfDay(for: endDate)
        let components = calendar.dateComponents([.day], from: startOfStartDate, to: startOfEndDate)
        let numberOfDays = (components.day ?? 30) + 1
        
        for dayOffset in 0..<numberOfDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfStartDate) else { continue }
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
        
        historyEntries = entries.reversed()
        
        // Check if we should show the local data tutorial
        // Show it when user views history with at least one non-zero count for the first time
        if !TutorialManager.shared.hasSeenHistoryDataTutorial {
            let hasNonZeroData = historyEntries.contains { $0.count > 0 }
            if hasNonZeroData {
                showingLocalDataTutorial = true
            }
        }
    }
    
    private func generateCSV() {
        guard selectedTrackable != nil else {
            csvContent = ""
            return
        }
        
        var lines: [String] = []
        lines.append("Date,Count")
        
        for entry in historyEntries {
            let row = "\(entry.dateString),\(entry.count)"
            lines.append(row)
        }
        
        csvContent = lines.joined(separator: "\n")
    }
    
    private func generateAllCSV() {
        guard !trackables.isEmpty else {
            allCSVContent = ""
            return
        }
        
        var header = "Date"
        for trackable in trackables {
            let escapedName = trackable.name.contains(",") ? "\"\(trackable.name)\"" : trackable.name
            header += ",\(escapedName)"
        }
        
        var lines: [String] = [header]
        
        var countsByTrackableAndDate: [Int64: [String: Int]] = [:]
        for trackable in trackables {
            let counts = BackendService.shared.getAllCounts(trackableId: trackable.id)
            var countsByDate: [String: Int] = [:]
            for count in counts {
                countsByDate[count.date] = count.count
            }
            countsByTrackableAndDate[trackable.id] = countsByDate
        }
        
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for dayOffset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dateString = dateFormatter.string(from: date)
            
            var row = dateString
            for trackable in trackables {
                let count = countsByTrackableAndDate[trackable.id]?[dateString] ?? 0
                row += ",\(count)"
            }
            lines.append(row)
        }
        
        allCSVContent = lines.joined(separator: "\n")
    }
}
