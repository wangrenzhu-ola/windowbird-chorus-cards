import SwiftUI

enum AppTab: Hashable {
    case morning
    case map
    case badges
}

struct AppShell: View {
    @State private var selectedTab: AppTab = .morning

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                MorningChorusView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Morning", systemImage: "sunrise.fill") }
            .tag(AppTab.morning)

            NavigationStack {
                NeighborhoodSoundMapView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Sound Map", systemImage: "map.fill") }
            .tag(AppTab.map)

            NavigationStack {
                BadgeRoostView(selectedTab: $selectedTab)
            }
            .tabItem { Label("Badges", systemImage: "rosette") }
            .tag(AppTab.badges)
        }
        .tint(Color.wbCyan)
        .preferredColorScheme(.dark)
        .toolbarBackground(Color.wbInk, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color.wbInk.opacity(0.94), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
