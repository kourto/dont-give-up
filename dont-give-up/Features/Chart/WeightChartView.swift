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
        Chart {
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight (lb)", entry.weight)
                )
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
        .padding()
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
