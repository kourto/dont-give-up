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

    @State private var isDarkMode = false

    var body: some View {
        NavigationStack {
            TabView {
                EntriesView(isDarkMode: isDarkMode)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Entries")
                    }

                WeightChartView(isDarkMode: isDarkMode)
                    .padding(.top, 8)
                    .tabItem {
                        Image(systemName: "chart.xyaxis.line")
                        Text("Chart")
                    }

                StatsView(isDarkMode: isDarkMode)
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Stats")
                    }
            }
            .navigationTitle("Dont give up!")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WeightEntry.self, inMemory: true)
}
