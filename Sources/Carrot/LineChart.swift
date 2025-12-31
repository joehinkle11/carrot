// SPDX-License-Identifier: GPL-2.0-or-later

import SwiftUI

/// A data point for the line chart
struct ChartDataPoint: Identifiable {
    let id: String
    let date: Date
    let value: Double
    let label: String
}

/// A simple line chart view built with pure SwiftUI (no Charts framework)
/// Compatible with both iOS and Android via Skip SwiftUI
struct LineChartView: View {
    let dataPoints: [ChartDataPoint]
    let lineColor: Color
    let fillColor: Color
    let showLabels: Bool
    
    init(
        dataPoints: [ChartDataPoint],
        lineColor: Color = .orange,
        fillColor: Color = .orange.opacity(0.2),
        showLabels: Bool = true
    ) {
        // Sort by date ascending for proper line drawing
        self.dataPoints = dataPoints.sorted { $0.date < $1.date }
        self.lineColor = lineColor
        self.fillColor = fillColor
        self.showLabels = showLabels
    }
    
    private var maxValue: Double {
        max(dataPoints.map { $0.value }.max() ?? 1, 1)
    }
    
    private var minValue: Double {
        0 // Always start from 0 for habit counts
    }
    
    private var valueRange: Double {
        maxValue - minValue
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let chartHeight = height - (showLabels ? 30 : 0)
            let chartTop: CGFloat = 10
            let usableHeight = chartHeight - chartTop
            
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    // Background grid lines
                    GridLinesView(
                        maxValue: maxValue,
                        height: usableHeight,
                        topPadding: chartTop
                    )
                    
                    // Fill area under the line
                    if dataPoints.count > 1 {
                        FillAreaPath(
                            dataPoints: dataPoints,
                            width: width,
                            height: usableHeight,
                            topPadding: chartTop,
                            maxValue: maxValue
                        )
                        .fill(fillColor)
                    }
                    
                    // Line path
                    if dataPoints.count > 1 {
                        LinePath(
                            dataPoints: dataPoints,
                            width: width,
                            height: usableHeight,
                            topPadding: chartTop,
                            maxValue: maxValue
                        )
                        .stroke(lineColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                    
                    // Data points dots
                    ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, point in
                        let x = xPosition(for: index, width: width)
                        let y = yPosition(for: point.value, height: usableHeight, topPadding: chartTop)
                        
                        Circle()
                            .fill(lineColor)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: chartHeight)
                
                // X-axis labels
                if showLabels && !dataPoints.isEmpty {
                    XAxisLabels(dataPoints: dataPoints, width: width)
                        .frame(height: 30)
                }
            }
        }
    }
    
    private func xPosition(for index: Int, width: CGFloat) -> CGFloat {
        guard dataPoints.count > 1 else { return width / 2 }
        let spacing = width / CGFloat(dataPoints.count - 1)
        return CGFloat(index) * spacing
    }
    
    private func yPosition(for value: Double, height: CGFloat, topPadding: CGFloat) -> CGFloat {
        guard valueRange > 0 else { return height / 2 + topPadding }
        let normalized = (value - minValue) / valueRange
        return topPadding + height - (CGFloat(normalized) * height)
    }
}

/// Path for the line connecting data points
struct LinePath: Shape {
    let dataPoints: [ChartDataPoint]
    let width: CGFloat
    let height: CGFloat
    let topPadding: CGFloat
    let maxValue: Double
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        guard dataPoints.count > 1 else { return path }
        
        let points = dataPoints.enumerated().map { index, point -> CGPoint in
            let x = calcXPosition(for: index, dataCount: dataPoints.count, width: width)
            let y = calcYPosition(for: point.value, maxValue: maxValue, height: height, topPadding: topPadding)
            return CGPoint(x: x, y: y)
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        return path
    }
}

/// Filled area under the line chart
struct FillAreaPath: Shape {
    let dataPoints: [ChartDataPoint]
    let width: CGFloat
    let height: CGFloat
    let topPadding: CGFloat
    let maxValue: Double
    
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        guard dataPoints.count > 1 else { return path }
        
        let points = dataPoints.enumerated().map { index, point -> CGPoint in
            let x = calcXPosition(for: index, dataCount: dataPoints.count, width: width)
            let y = calcYPosition(for: point.value, maxValue: maxValue, height: height, topPadding: topPadding)
            return CGPoint(x: x, y: y)
        }
        
        // Start at bottom left
        path.move(to: CGPoint(x: 0, y: topPadding + height))
        
        // Go to first data point
        path.addLine(to: points[0])
        
        // Draw line through all points
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        // Go to bottom right and close
        path.addLine(to: CGPoint(x: width, y: topPadding + height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Helper functions for Shape calculations

private func calcXPosition(for index: Int, dataCount: Int, width: CGFloat) -> CGFloat {
    guard dataCount > 1 else { return width / 2 }
    let spacing = width / CGFloat(dataCount - 1)
    return CGFloat(index) * spacing
}

private func calcYPosition(for value: Double, maxValue: Double, height: CGFloat, topPadding: CGFloat) -> CGFloat {
    guard maxValue > 0 else { return height / 2 + topPadding }
    let normalized = value / maxValue
    return topPadding + height - (CGFloat(normalized) * height)
}

/// Horizontal grid lines for reference
struct GridLinesView: View {
    let maxValue: Double
    let height: CGFloat
    let topPadding: CGFloat
    
    private var gridValues: [Double] {
        // Show 4 grid lines
        guard maxValue > 0 else { return [0] }
        let step = maxValue / 4
        return stride(from: 0, through: maxValue, by: step).map { $0 }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(gridValues, id: \.self) { value in
                let y = yPosition(for: value)
                
                HStack(spacing: 4) {
                    Text("\(Int(value))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: 24, alignment: .trailing)
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .offset(y: y - 6)
            }
        }
    }
    
    private func yPosition(for value: Double) -> CGFloat {
        guard maxValue > 0 else { return height / 2 + topPadding }
        let normalized = value / maxValue
        return topPadding + height - (CGFloat(normalized) * height)
    }
}

/// X-axis date labels
struct XAxisLabels: View {
    let dataPoints: [ChartDataPoint]
    let width: CGFloat
    
    private var labelIndices: [Int] {
        guard dataPoints.count > 0 else { return [] }
        if dataPoints.count <= 7 {
            return Array(0..<dataPoints.count)
        }
        // Show first, last, and a few in between
        let step = max(1, dataPoints.count / 5)
        var indices: [Int] = []
        for i in stride(from: 0, to: dataPoints.count, by: step) {
            indices.append(i)
        }
        if !indices.contains(dataPoints.count - 1) {
            indices.append(dataPoints.count - 1)
        }
        return indices
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(labelIndices, id: \.self) { index in
                    let x = xPosition(for: index)
                    Text(dataPoints[index].label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .position(x: x, y: 15)
                }
            }
        }
    }
    
    private func xPosition(for index: Int) -> CGFloat {
        guard dataPoints.count > 1 else { return width / 2 }
        let spacing = width / CGFloat(dataPoints.count - 1)
        return CGFloat(index) * spacing
    }
}

/// Chart container with title and padding
struct ChartContainer: View {
    let title: String
    let dataPoints: [ChartDataPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            if dataPoints.isEmpty {
                emptyChart
            } else {
                LineChartView(dataPoints: dataPoints)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var emptyChart: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No data to display")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}
