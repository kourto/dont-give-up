//
//
//
//
//  Created by Yves Courteau on 2025-09-13.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var themePrefs: [ThemePreference]
    @Query(sort: \WeightEntry.date, order: .reverse) private var latestEntries: [WeightEntry]
    @Query(sort: \Objective.weight, order: .reverse) private var objectives: [Objective]

    @State private var isDarkMode = false
    @State private var selectedTab: Int = 0

    init() {}

    private var progressPercentText: String? {
        guard let latest = latestEntries.first,
              let oldest = latestEntries.last else {
            return nil
        }

        let highestPending = objectives.first(where: { $0.reachedAt == nil })
        let highestAny = objectives.first
        guard let target = highestPending ?? highestAny else {
            return nil
        }

        let start = oldest.weight
        let current = latest.weight
        let goal = target.weight

        let pct: Double
        if start == goal {
            if start > goal {
                pct = current <= goal ? 100 : 0
            } else {
                pct = current >= goal ? 100 : 0
            }
        } else if start > goal {
            let totalDelta = max(0.0001, start - goal)
            pct = ((start - current) / totalDelta) * 100.0
        } else {
            let totalDelta = max(0.0001, goal - start)
            pct = ((current - start) / totalDelta) * 100.0
        }

        let clamped = max(0.0, min(pct, 100.0))
        return String(format: "%.0f%%", clamped)
    }

    #if canImport(UIKit)
    private func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = .clear
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    #endif

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                EntriesView(isDarkMode: isDarkMode)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Entries")
                    }
                    .tag(0)

                WeightChartView(isDarkMode: isDarkMode)
                    .padding(.top, 8)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Chart")
                    }
                    .tag(1)

                StatsView(isDarkMode: isDarkMode)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
                    .tag(2)

                ObjectiveView(isDarkMode: isDarkMode)
                    .tabItem {
                        Image(systemName: "target")
                        Text("Objective")
                    }
                    .tag(3)
            }
            .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackgroundVisibility(.visible, for: .tabBar)
            .navigationTitle("Dont give up!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            isDarkMode.toggle()
                            if let pref = themePrefs.first {
                                pref.isDarkMode = isDarkMode
                            } else {
                                let pref = ThemePreference(isDarkMode: isDarkMode)
                                modelContext.insert(pref)
                            }
                        }
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                    }
                    .accessibilityLabel("Toggle theme")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let text = progressPercentText {
                        Button(action: { selectedTab = 3 }) {
                            HStack(spacing: 6) {
                                Image(systemName: "target")
                                    .imageScale(.medium)
                                    .foregroundStyle(isDarkMode ? Color.white : Color.black)
                                Text(text)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(isDarkMode ? Color.white : Color.black)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open Objectives. Goal progress: \(text)")
                    }
                }
            }
        }
        .tint(isDarkMode ? .white : .black)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            if let pref = themePrefs.first {
                isDarkMode = pref.isDarkMode
            } else {
                let pref = ThemePreference(isDarkMode: false)
                modelContext.insert(pref)
                isDarkMode = pref.isDarkMode
            }
            applyTabBarAppearance()
        }
        .onChange(of: isDarkMode) { _ in
            applyTabBarAppearance()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [WeightEntry.self, ThemePreference.self, Objective.self], inMemory: true)
}
