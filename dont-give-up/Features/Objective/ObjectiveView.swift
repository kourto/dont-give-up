//
//
//
//
//  Created by Yves Courteau on 2025-09-15.
//

import SwiftUI
import SwiftData

struct ObjectiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Objective.weight, order: .reverse) private var objectives: [Objective]

    @State private var showAddSheet = false
    @State private var weightText: String = ""

    var isDarkMode: Bool = false

    var body: some View {
        List {
            if objectives.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(isDarkMode ? .white : .black)
                    Text("No objectives yet")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    Text("Tap + to add a target weight")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            ForEach(objectives) { obj in
                ObjectiveRow(obj: obj, isDarkMode: isDarkMode)
                    .listRowBackground(Color.clear)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(accessibilityLabel(for: obj))
            }
            .onDelete(perform: deleteObjectives)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(isDarkMode ? Color.black : Color.white)
        .overlay(alignment: .bottomTrailing) {
            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
            }
            .accessibilityLabel("Add objective")
            .frame(width: 56, height: 56)
            .background(
                Circle().fill(
                    LinearGradient(colors: isDarkMode ? [Color.white, Color.white.opacity(0.85)] : [Color.black, Color.black.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            )
            .foregroundColor(isDarkMode ? .black : .white)
            .overlay(Circle().stroke(isDarkMode ? Color.black : Color.white, lineWidth: 2))
            .shadow(color: (isDarkMode ? Color.white.opacity(0.0) : Color.black.opacity(0.25)), radius: 10, x: 0, y: 6)
            .padding(.trailing, 16)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showAddSheet) {
            addObjectiveSheet
                .presentationDetents([.height(180)])
                .presentationDragIndicator(.hidden)
                .interactiveDismissDisabled(false)
        }
        .padding(.top, 4)
        .background(isDarkMode ? Color.black : Color.white)
        .tint(isDarkMode ? .white : .black)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .navigationTitle("Objective")
    }

    private var addObjectiveSheet: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Target Weight (lb)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(isDarkMode ? .white : .black)
                TextField("e.g. 180", text: $weightText)
                    .keyboardType(.decimalPad)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(colors: isDarkMode ? [Color.white.opacity(0.06), Color.white.opacity(0.02)] : [Color.black.opacity(0.04), Color.black.opacity(0.01)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    )
                    .foregroundStyle(isDarkMode ? .white : .black)
            }

            Button(action: saveObjective) {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .foregroundColor(isDarkMode ? .black : .white)
            .background(isDarkMode ? Color.white : Color.black)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isDarkMode ? Color.black : Color.white, lineWidth: 2))
            .disabled(Double(weightText.replacingOccurrences(of: ",", with: ".")) == nil)
            .opacity(Double(weightText.replacingOccurrences(of: ",", with: ".")) == nil ? 0.5 : 1.0)
        }
        .padding(20)
        .background(isDarkMode ? Color.black : Color.white)
        .tint(isDarkMode ? .white : .black)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func saveObjective() {
        guard let w = Double(weightText.replacingOccurrences(of: ",", with: ".")) else { return }
        withAnimation {
            let obj = Objective(weight: w)
            modelContext.insert(obj)
            weightText = ""
            showAddSheet = false
        }
    }

    private func deleteObjectives(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(objectives[index])
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }

    private func reachedText(for obj: Objective) -> String {
        if let d = obj.reachedAt {
            return "Reached: \(formattedDate(d))"
        } else {
            return "Still not reached"
        }
    }

    private func accessibilityLabel(for obj: Objective) -> String {
        if let d = obj.reachedAt {
            return "Objective: \(obj.weight) pounds, added on \(formattedDate(obj.createdAt)), reached on \(formattedDate(d))"
        } else {
            return "Objective: \(obj.weight) pounds, added on \(formattedDate(obj.createdAt)), still not reached"
        }
    }
}

private struct ObjectiveRow: View {
    let obj: Objective
    let isDarkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(format: "%.1f lb", obj.weight))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Text(reachedText)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Added: \(formattedDate(obj.createdAt))")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(colors: isDarkMode ? [Color.white.opacity(0.06), Color.white.opacity(0.02)] : [Color.black.opacity(0.04), Color.black.opacity(0.01)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        )
    }

    private var reachedText: String {
        if let d = obj.reachedAt {
            return "Reached: \(formattedDate(d))"
        } else {
            return "Still not reached"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}
