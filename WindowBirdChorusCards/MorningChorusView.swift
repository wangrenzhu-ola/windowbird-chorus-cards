import SwiftUI

struct MorningChorusView: View {
    @Environment(ListenStore.self) private var listenStore
    @Environment(PremiumStore.self) private var premiumStore
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    todayCard
                    privacyCard
                    recentCard
                    premiumEntry
                }
                .padding(20)
            }
        }
        .navigationTitle("Morning Chorus")
        .toolbarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WindowBird Chorus Cards")
                .font(.largeTitle.bold())
                .foregroundStyle(Color(red: 0.14, green: 0.20, blue: 0.17))
            Text("Turn two minutes of window birdsong into a private rhythm, direction, weather, and mood card.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var todayCard: some View {
        BirdSilhouetteCard(
            shape: listenStore.favoriteShape ?? .trill,
            title: "Today’s soft dawn listen",
            subtitle: "Pick the rhythm you heard near your window, then turn it into a private chorus card."
        )
        .overlay(alignment: .bottomTrailing) {
            NavigationLink {
                SoundShapePickerView(selectedTab: $selectedTab, draft: ListenDraft())
            } label: {
                Text("Start a Listen")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.78, green: 0.34, blue: 0.20), in: Capsule())
                    .foregroundStyle(.white)
            }
            .padding(20)
            .accessibilityLabel("Start a new window listen")
        }
    }

    private var privacyCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Label("Private by design", systemImage: "lock.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var recentCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text(listenStore.activeCards.isEmpty ? "Starter action" : "Latest listen")
                    .font(.headline)
                if let latest = listenStore.activeCards.first {
                    ListenCardRow(card: latest)
                    NavigationLink("Edit Latest Card") {
                        WindowListenDetailView(selectedTab: $selectedTab, card: latest)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Your sound map is quiet for now. Start with the rhythm you can describe, not a bird name you have to know.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    NavigationLink("Choose a Sound Shape") {
                        SoundShapePickerView(selectedTab: $selectedTab, draft: ListenDraft())
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var premiumEntry: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Premium Dawn Pack", systemImage: premiumStore.isUnlocked ? "checkmark.seal.fill" : "sparkles")
                        .font(.headline)
                    Spacer()
                    Text(premiumStore.accessState.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: Capsule())
                }
                Text("Extra visual themes and sticker roosts are optional. The core free listening flow stays open.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("Open Badge Roost") {
                    selectedTab = .badges
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

struct ListenCardRow: View {
    let card: ListenCard

    var body: some View {
        HStack(spacing: 12) {
            BirdSilhouette()
                .fill(Color(red: 0.21, green: 0.31, blue: 0.27))
                .frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 4) {
                Text(card.soundShape.displayName)
                    .font(.headline)
                Text("\(card.direction.displayName) • \(card.weather.displayName) • \(card.mood.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !card.note.isEmpty {
                    Text(card.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Listen card, \(card.soundShape.displayName), \(card.direction.displayName), \(card.weather.displayName), \(card.mood.displayName)")
    }
}
