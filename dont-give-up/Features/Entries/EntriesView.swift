//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//


import SwiftUI
import SwiftData

struct EntriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]
    @Query private var objectives: [Objective]
    
    // Local UI state
    @State private var showAddSheet = false
    @State private var newDate = Date()
    @State private var weightText = ""
    
    var isDarkMode: Bool

    init(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                HStack {
                    Text(entry.date, style: .date)
                    Spacer()
                    Text(String(format: "%.1f lb", entry.weight))
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(formattedDate(entry.date)), \(entry.weight) pounds")
            }
            .onDelete(perform: deleteEntries)
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
            }
            .accessibilityLabel("Add weight entry")
            .frame(width: 56, height: 56)
            .background(isDarkMode ? Color.white : Color.black)
            .foregroundColor(isDarkMode ? .black : .white)
            .clipShape(Circle())
            .overlay(Circle().stroke(isDarkMode ? Color.black : Color.white, lineWidth: 2))
            .shadow(color: (isDarkMode ? Color.white.opacity(0.0) : Color.black.opacity(0.2)), radius: 6, x: 0, y: 3)
            .padding(.trailing, 16)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddSheet) {
            AddEntrySheet(isDarkMode: isDarkMode, newDate: $newDate, weightText: $weightText) {
                saveEntry()
            }
            .presentationDetents([.height(240)])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(false)
        }
    }

    private func saveEntry() {
        guard let weight = Double(weightText.replacingOccurrences(of: ",", with: ".")) else { return }
        withAnimation {
            let entry = WeightEntry(date: newDate, weight: weight)
            modelContext.insert(entry)
            // Mark objectives as reached if this weight is below or equal to their target
            for obj in objectives {
                if obj.reachedAt == nil && weight <= obj.weight {
                    obj.reachedAt = entry.date
                }
            }
            weightText = ""
            newDate = Date()
            showAddSheet = false
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            // Delete selected entries
            for index in offsets {
                modelContext.delete(entries[index])
            }
            // After deletions, recompute objectives' reachedAt based on remaining entries
            recomputeObjectivesReached()
        }
    }

    private func recomputeObjectivesReached() {
        // Fetch all remaining entries to ensure we compute from current state
        let descriptor = FetchDescriptor<WeightEntry>()
        let allEntries = (try? modelContext.fetch(descriptor)) ?? []

        for obj in objectives {
            // For weight-loss goals, an objective is reached when any entry is <= target weight
            if let earliestDate = allEntries
                .filter({ $0.weight <= obj.weight })
                .map({ $0.date })
                .min() {
                obj.reachedAt = earliestDate
            } else {
                // No entry meets the objective anymore; reset
                obj.reachedAt = nil
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}
