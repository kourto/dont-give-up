//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import SwiftUI
import SwiftData
import Charts

struct WeightChartView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    var isDarkMode: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Chart {
                // Smooth line across all entries
                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight (lb)", entry.weight)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(isDarkMode ? .white : .black)
                }

                // Only show points (dots) for the first and last entries, with labels
                if let first = entries.first {
                    PointMark(
                        x: .value("Date", first.date),
                        y: .value("Weight (lb)", first.weight)
                    )
                    .symbolSize(60)
                    .foregroundStyle(isDarkMode ? .white : .black)
                    .annotation(position: .top) {
                        Text(String(format: "%.1f lb", first.weight))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
                if entries.count > 1, let last = entries.last {
                    PointMark(
                        x: .value("Date", last.date),
                        y: .value("Weight (lb)", last.weight)
                    )
                    .symbolSize(60)
                    .foregroundStyle(isDarkMode ? .white : .black)
                    .annotation(position: .top) {
                        Text(String(format: "%.1f lb", last.weight))
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
            }
            .chartYScale(domain: inferredYDomain())
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .chartPlotStyle { plot in
                plot.background(Color.clear)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 0)
            .padding(.vertical, 8)
        }
        .background(isDarkMode ? Color.black : Color.white)
    }

    private func inferredYDomain() -> ClosedRange<Double> {
        let values = entries.map { $0.weight }
        guard let minVal = values.min(), let maxVal = values.max() else {
            return 0...1
        }
        if minVal == maxVal {
            let pad: Double = 1.0
            return (minVal - pad)...(maxVal + pad)
        }
        let padding = Swift.max(0.5, (maxVal - minVal) * 0.1)
        return (minVal - padding)...(maxVal + padding)
    }
}
