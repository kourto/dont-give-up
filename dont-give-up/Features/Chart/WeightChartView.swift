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
        VStack(alignment: .leading, spacing: 12) {
            Chart {
                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight (lb)", entry.weight)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(isDarkMode ? .white : .black)
                    PointMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight (lb)", entry.weight)
                    )
                    .foregroundStyle(isDarkMode ? .white : .black)
                }
            }
            .chartYScale(domain: inferredYDomain())
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .chartPlotStyle { plot in
                plot.background(Color.clear)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(colors: isDarkMode ? [Color.white.opacity(0.06), Color.white.opacity(0.02)] : [Color.black.opacity(0.04), Color.black.opacity(0.01)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.6), lineWidth: 1)
                    )
            )
        }
        .padding()
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
