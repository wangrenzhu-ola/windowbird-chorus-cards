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

                ScrollableOptionPicker(
                    title: "Weather tag",
                    items: Array(WeatherTag.allCases),
                    selection: $draft.weather,
                    label: { $0.displayName }
                )

                ScrollableOptionPicker(
                    title: "Mood tag",
                    items: Array(MoodTag.allCases),
                    selection: $draft.mood,
                    label: { $0.displayName }
                )
            }
        }
    }
}

private struct ScrollableOptionPicker<Item: Hashable & Identifiable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Item
    let label: (Item) -> String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    let isSelected = item.id == selection.id
                    Button {
                        selection = item
                    } label: {
                        Text(label(item))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isSelected ? Color.wbInk : Color.wbText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(isSelected ? Color.wbCyan : Color.wbPanelRaised.opacity(0.92))
                            )
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(isSelected ? Color.wbCyan.opacity(0.45) : Color.wbCyan.opacity(0.22), lineWidth: 1)
                            )
                            // Prevent the system segmented control from truncating labels with ellipses.
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .accessibilityLabel("\(title): \(label(item))")
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityElement(children: .contain)
    }
}
