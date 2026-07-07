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
                .foregroundStyle(Color.wbText)
            Text("Turn two minutes of window birdsong into a private rhythm, direction, weather, and mood card.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
        .accessibilityElement(children: .combine)
    }

    private var todayCard: some View {
        let shape = listenStore.favoriteShape ?? .trill
        return GlassSurface(radius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.wbInk)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.wbCyan.opacity(0.42), lineWidth: 1)
                            }
                        BirdSilhouette()
                            .stroke(Color.wbCyan, lineWidth: 2)
                            .padding(14)
                        Text(shape.shortGlyph)
                            .font(.caption2.weight(.black).monospaced())
                            .foregroundStyle(Color.wbLime)
                            .offset(y: 25)
                    }
                    .frame(width: 74, height: 74)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today’s soft dawn listen")
                            .font(.headline.weight(.black))
                            .foregroundStyle(Color.wbText)
                        Text("Pick the rhythm you heard near your window, then turn it into a private chorus card.")
                            .font(.subheadline)
                            .foregroundStyle(Color.wbMuted)
                    }
                }

                Divider()
                    .overlay(Color.wbCyan.opacity(0.24))

                HStack {
                    Text("NEW LISTEN / LOCAL ONLY")
                        .font(.caption2.weight(.bold).monospaced())
                        .foregroundStyle(Color.wbLime)
                    Spacer(minLength: 12)
                    startListenButton
                }
            }
        }
    }

    private var startListenButton: some View {
        NavigationLink {
            SoundShapePickerView(selectedTab: $selectedTab, draft: ListenDraft())
        } label: {
            Text("Start a Listen")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(Color.wbCyan)
                        .shadow(color: Color.wbCyan.opacity(0.45), radius: 14)
                }
                .foregroundStyle(Color.wbInk)
        }
        .accessibilityLabel("Start a new window listen")
    }

    private var privacyCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Label("Private by design", systemImage: "lock.fill")
                    .font(.headline)
                Text(AppCopy.privacyBoundary)
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)
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
                    WindowViewPhotoReadOnly(
                        card: latest,
                        screenFraction: 0.48,
                        caption: "Latest window view"
                    )
                    ListenCardRow(card: latest)
                    NavigationLink("Edit Latest Card") {
                        WindowListenDetailView(selectedTab: $selectedTab, card: latest)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("Your sound map is quiet for now. Start with the rhythm you can describe, not a bird name you have to know.")
                        .font(.subheadline)
                        .foregroundStyle(Color.wbMuted)
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
                        .foregroundStyle(Color.wbInk)
                        .background(Color.wbLime, in: Capsule())
                }
                Text("Extra visual themes and sticker roosts are optional. The core free listening flow stays open.")
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)
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
            if let filename = card.windowPhotoFilename,
               let image = WindowPhotoStore.load(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.wbCyan.opacity(0.42), lineWidth: 1)
                    }
            } else {
                BirdSilhouette()
                    .fill(Color.wbCyan.opacity(0.82))
                    .frame(width: 42, height: 42)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(card.soundShape.displayName)
                    .font(.headline)
                Text("\(card.direction.displayName) • \(card.weather.displayName) • \(card.mood.displayName)")
                    .font(.caption)
                    .foregroundStyle(Color.wbMuted)
                if !card.note.isEmpty {
                    Text(card.note)
                        .font(.caption)
                        .foregroundStyle(Color.wbMuted)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Listen card, \(card.soundShape.displayName), \(card.direction.displayName), \(card.weather.displayName), \(card.mood.displayName)")
    }
}
