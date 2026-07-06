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
                    directionSection
                    weatherMoodSection
                    moodTip
                    NavigationLink {
                        WindowListenDetailView(selectedTab: $selectedTab, draft: draft)
                    } label: {
                        Label("Review Listen Card", systemImage: "square.and.pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("Review the selected sound shape in Window Listen Detail")
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
            Text("No species guess is needed. Pick the rhythm, direction, weather, and mood you actually noticed.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
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
                        Text(shape.displayName)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 106, alignment: .leading)
                    .padding(14)
                    .background(cardBackground(for: shape), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(shape == draft.soundShape ? Color(red: 0.78, green: 0.34, blue: 0.20) : .clear, lineWidth: 3)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(shape.displayName)")
                .accessibilityAddTraits(shape == draft.soundShape ? .isSelected : [])
            }
        }
    }

    private var directionSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 16) {
                Text("Direction ring")
                    .font(.headline)
                HStack(alignment: .center, spacing: 20) {
                    DirectionRing(direction: draft.direction)
                    Picker("Direction", selection: $draft.direction) {
                        ForEach(ListenDirection.allCases) { direction in
                            Text(direction.displayName).tag(direction)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxHeight: 142)
                    .accessibilityLabel("Listen direction")
                }
            }
        }
    }

    private var weatherMoodSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 14) {
                Text("Weather and mood")
                    .font(.headline)
                Picker("Weather", selection: $draft.weather) {
                    ForEach(WeatherTag.allCases) { weather in
                        Text(weather.displayName).tag(weather)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Weather tag")

                Picker("Mood", selection: $draft.mood) {
                    ForEach(MoodTag.allCases) { mood in
                        Text(mood.displayName).tag(mood)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Mood tag")
            }
        }
    }

    private var moodTip: some View {
        let card = BirdMoodCard.all.first { $0.shape == draft.soundShape } ?? BirdMoodCard.all[0]
        return BirdSilhouetteCard(shape: card.shape, title: card.shape.displayName, subtitle: card.tip)
    }

    private func cardBackground(for shape: SoundShape) -> some ShapeStyle {
        shape == draft.soundShape ? AnyShapeStyle(Color.white.opacity(0.82)) : AnyShapeStyle(Color.white.opacity(0.42))
    }
}
