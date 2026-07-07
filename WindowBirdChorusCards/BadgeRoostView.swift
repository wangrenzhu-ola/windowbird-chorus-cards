import SwiftUI

struct BadgeRoostView: View {
    @Environment(ListenStore.self) private var listenStore

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    badgeGrid
                }
                .padding(20)
            }
        }
        .navigationTitle("Badge Roost")
        .toolbarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exploration badges")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("Quiet milestones from saved listens. Badges stay on your private sound map.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var badgeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            ForEach(SoundBadgeType.allCases) { badgeType in
                let earned = listenStore.badges.first { $0.type == badgeType }
                GlassSurface(radius: 22) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: earned == nil ? "circle.dashed" : "rosette")
                            .font(.title2)
                            .foregroundStyle(earned == nil ? Color.wbMuted : Color.wbLime)
                        Text(badgeType.displayName)
                            .font(.headline)
                        Text(earned == nil ? badgeType.description : "Earned for your private sound map.")
                            .font(.caption)
                            .foregroundStyle(Color.wbMuted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
                }
                .accessibilityLabel("Badge \(badgeType.displayName), \(earned == nil ? "locked" : "earned")")
            }
        }
    }
}
