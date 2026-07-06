import SwiftUI

struct NeighborhoodSoundMapView: View {
    @Environment(ListenStore.self) private var listenStore
    @Binding var selectedTab: AppTab
    @State private var showArchive = false
    @State private var actionMessage: String?

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    NeighborhoodSoundDots(cards: listenStore.activeCards)
                    if let actionMessage {
                        savedBanner(actionMessage)
                    }
                    activeSection
                    archiveSection
                    premiumEntry
                }
                .padding(20)
            }
        }
        .navigationTitle("Neighborhood Sound Map")
        .toolbarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Neighborhood Sound Map")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("Review saved rhythm, direction, weather, and mood patterns. This is a private memory map, not a live community service.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var activeSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text("Saved listens")
                    .font(.headline)
                if listenStore.activeCards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your sound map is quiet for now.")
                            .font(.subheadline.weight(.semibold))
                        Text("Start a listen from Morning Chorus to place the first neighborhood sound dot.")
                            .font(.subheadline)
                            .foregroundStyle(Color.wbMuted)
                        Button("Go to Morning Chorus") {
                            selectedTab = .morning
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.wbCyan)
                    }
                } else {
                    ForEach(listenStore.activeCards) { card in
                        NavigationLink {
                            WindowListenDetailView(selectedTab: $selectedTab, card: card)
                        } label: {
                            ListenCardRow(card: card)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                    Text("Swipe-style actions are also available inside Window Listen Detail: edit, archive, or delete.")
                        .font(.caption)
                        .foregroundStyle(Color.wbMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var archiveSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    withAnimation { showArchive.toggle() }
                } label: {
                    HStack {
                        Label("Archived or deleted state", systemImage: "archivebox.fill")
                            .font(.headline)
                        Spacer()
                        Image(systemName: showArchive ? "chevron.up" : "chevron.down")
                    }
                }
                .buttonStyle(.plain)

                if showArchive {
                    if listenStore.archivedCards.isEmpty {
                        Text("No archived listen cards yet. Archive from Window Listen Detail when a card should leave the active map.")
                            .font(.subheadline)
                            .foregroundStyle(Color.wbMuted)
                    } else {
                        ForEach(listenStore.archivedCards) { card in
                            HStack(alignment: .top, spacing: 12) {
                                ListenCardRow(card: card)
                                Spacer()
                                Button("Delete", role: .destructive) {
                                    delete(card)
                                }
                                .font(.caption)
                            }
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var premiumEntry: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Premium map layers", systemImage: "sparkles")
                    .font(.headline)
                Text("Optional sticker roosts and dawn themes live in Badge Roost. Your saved cards stay readable without Premium.")
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)
                Button("Open Premium Boundary") {
                    selectedTab = .badges
                }
                .buttonStyle(.bordered)
                .tint(Color.wbCyan)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func savedBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.wbLime)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.wbText)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.wbPanelRaised.opacity(0.94), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.wbLime.opacity(0.42), lineWidth: 1)
        }
    }

    private func delete(_ card: ListenCard) {
        do {
            try listenStore.delete(id: card.id)
            actionMessage = "Deleted archived listen card."
        } catch {
            actionMessage = error.localizedDescription
        }
    }
}
