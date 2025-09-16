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
            ForEach(objectives) { obj in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(String(format: "%.1f lb", obj.weight))
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Text(reachedText(for: obj))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Added: \(formattedDate(obj.createdAt))")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel(for: obj))
            }
            .onDelete(perform: deleteObjectives)
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: { showAddSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
            }
            .accessibilityLabel("Add objective")
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
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isDarkMode ? .white : .black)
                TextField("e.g. 180", text: $weightText)
                    .keyboardType(.decimalPad)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isDarkMode ? Color.white : Color.black, lineWidth: 1.5)
                    )
                    .foregroundStyle(isDarkMode ? .white : .black)
            }

            Button(action: saveObjective) {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
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
