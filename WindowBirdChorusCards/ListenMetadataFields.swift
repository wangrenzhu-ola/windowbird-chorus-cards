import SwiftUI

struct ListenMetadataFields: View {
    @Binding var draft: ListenDraft

    var body: some View {
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

                Divider()
                    .overlay(Color.wbCyan.opacity(0.24))

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
}
