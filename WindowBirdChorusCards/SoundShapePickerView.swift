import SwiftUI

struct SoundShapePickerView: View {
    @Binding var selectedTab: AppTab
    @State var draft: ListenDraft

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    intro
                    shapeGrid
                    moodTip
                    continueLink
                }
                .padding(20)
            }
        }
        .navigationTitle("Sound Shape Picker")
        .toolbarTitleDisplayMode(.inline)
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What shape did the sound make?")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("No species guess is needed. Pick the rhythm you actually noticed — direction, weather, and mood come on the next screen.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var continueLink: some View {
        NavigationLink {
            WindowListenDetailView(selectedTab: $selectedTab, draft: draft)
        } label: {
            Label("Continue to Listen Card", systemImage: "arrow.right.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Color.wbCyan)
        .accessibilityLabel("Continue to Window Listen Detail")
    }

    private var shapeGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 12)], spacing: 12) {
            ForEach(SoundShape.allCases) { shape in
                Button {
                    draft.soundShape = shape
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(shape.shortGlyph)
                            .font(.largeTitle.weight(.black))
                            .foregroundStyle(shape == draft.soundShape ? Color.wbInk : Color.wbCyan)
                        Text(shape.displayName)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(shape == draft.soundShape ? Color.wbInk : Color.wbText)
                    }
                    .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
                    .padding(14)
                    .background(cardBackground(for: shape), in: UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 6, bottomTrailingRadius: 24, topTrailingRadius: 6, style: .continuous))
                    .overlay {
                        UnevenRoundedRectangle(topLeadingRadius: 24, bottomLeadingRadius: 6, bottomTrailingRadius: 24, topTrailingRadius: 6, style: .continuous)
                            .stroke(shape == draft.soundShape ? Color.wbLime : Color.wbCyan.opacity(0.26), lineWidth: shape == draft.soundShape ? 3 : 1)
                    }
                    .shadow(color: shape == draft.soundShape ? Color.wbLime.opacity(0.28) : .clear, radius: 14, y: 8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(shape.displayName)")
                .accessibilityAddTraits(shape == draft.soundShape ? .isSelected : [])
            }
        }
    }

    private var moodTip: some View {
        let card = BirdMoodCard.all.first { $0.shape == draft.soundShape } ?? BirdMoodCard.all[0]
        return BirdSilhouetteCard(shape: card.shape, title: card.shape.displayName, subtitle: card.tip)
    }

    private func cardBackground(for shape: SoundShape) -> some ShapeStyle {
        shape == draft.soundShape
            ? AnyShapeStyle(
                LinearGradient(
                    colors: [Color.wbLime, Color.wbCyan],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            : AnyShapeStyle(Color.wbPanelRaised.opacity(0.90))
    }
}
