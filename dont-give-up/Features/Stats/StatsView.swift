//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \WeightEntry.date, order: .forward) private var entries: [WeightEntry]
    var isDarkMode: Bool = false

    private var sortedEntries: [WeightEntry] { entries.sorted { $0.date < $1.date } }
    private var weights: [Double] { entries.map { $0.weight } }

    private var minWeight: Double? { weights.min() }
    private var maxWeight: Double? { weights.max() }

    private var totalLoss: Double {
        guard let first = sortedEntries.first?.weight, let last = sortedEntries.last?.weight else { return 0 }
        return max(0, first - last)
    }

    private var avgWeeklyLoss: Double {
        guard let start = sortedEntries.first?.date, let end = sortedEntries.last?.date, end > start else { return 0 }
        let seconds = end.timeIntervalSince(start)
        let weeks = seconds / (60 * 60 * 24 * 7)
        if weeks <= 0 { return 0 }
        return totalLoss / weeks
    }

    private var maxWeeklyLoss: Double {
        if sortedEntries.isEmpty { return 0 }
        let calendar = Calendar.current
        var grouped: [String: [Double]] = [:]
        for e in sortedEntries {
            let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: e.date)
            let key = "\(comps.yearForWeekOfYear ?? 0)-\(comps.weekOfYear ?? 0)"
            grouped[key, default: []].append(e.weight)
        }
        var weekly: [(year: Int, week: Int, avg: Double)] = []
        for (key, ws) in grouped {
            let parts = key.split(separator: "-")
            let y = Int(parts.first ?? "0") ?? 0
            let w = Int(parts.last ?? "0") ?? 0
            let avg = ws.reduce(0, +) / Double(ws.count)
            weekly.append((year: y, week: w, avg: avg))
        }
        weekly.sort { ($0.year, $0.week) < ($1.year, $1.week) }
        guard weekly.count >= 2 else { return 0 }
        var maxDrop: Double = 0
        for i in 1..<weekly.count {
            let drop = weekly[i-1].avg - weekly[i].avg
            if drop > maxDrop { maxDrop = drop }
        }
        return max(0, maxDrop)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            statRow(title: "Maximum", value: formattedWeight(maxWeight))
            statRow(title: "Minimum", value: formattedWeight(minWeight))
            statRow(title: "Total Loss", value: String(format: "%.1f lb", totalLoss))
            statRow(title: "Avg Loss / week", value: String(format: "%.2f lb/week", avgWeeklyLoss))
            statRow(title: "Max Loss Between Weeks", value: String(format: "%.1f lb", maxWeeklyLoss))
            Spacer()
        }
        .padding(20)
        .navigationTitle("Statistics")
        .background(isDarkMode ? Color.black : Color.white)
        .tint(isDarkMode ? .white : .black)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    @ViewBuilder
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .regular))
        }
        .foregroundStyle(isDarkMode ? .white : .black)
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDarkMode ? Color.white : Color.black, lineWidth: 1.5)
        )
    }

    private func formattedWeight(_ w: Double?) -> String {
        guard let w else { return "—" }
        return String(format: "%.1f lb", w)
    }
}
