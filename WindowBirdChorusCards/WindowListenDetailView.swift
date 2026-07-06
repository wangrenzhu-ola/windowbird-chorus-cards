import SwiftUI

struct WindowListenDetailView: View {
    @Environment(ListenStore.self) private var listenStore
    @Binding var selectedTab: AppTab
    @State private var draft: ListenDraft
    @State private var currentCardID: UUID?
    @State private var originalHeardAt: Date?
    @State private var errorMessage: String?
    @State private var savedMessage: String?

    init(selectedTab: Binding<AppTab>, draft: ListenDraft) {
        _selectedTab = selectedTab
        _draft = State(initialValue: draft)
        _currentCardID = State(initialValue: nil)
        _originalHeardAt = State(initialValue: nil)
    }

    init(selectedTab: Binding<AppTab>, card: ListenCard) {
        _selectedTab = selectedTab
        _draft = State(initialValue: ListenDraft(card: card))
        _currentCardID = State(initialValue: card.id)
        _originalHeardAt = State(initialValue: card.heardAt)
    }

    var body: some View {
        ZStack {
            DawnGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailHeader
                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    if let savedMessage {
                        savedBanner(savedMessage)
                    }
                    BirdSilhouetteCard(
                        shape: draft.soundShape,
                        title: draft.soundShape.displayName,
                        subtitle: "\(draft.direction.displayName) • \(draft.weather.displayName) • \(draft.mood.displayName)"
                    )
                    editFields
                    actions
                }
                .padding(20)
            }
        }
        .navigationTitle("Window Listen Detail")
        .toolbarTitleDisplayMode(.inline)
    }

    private var detailHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentCardID == nil ? "Create a private listen card" : "Edit listen card")
                .font(.title.bold())
            Text("Editing state is local until you save. Archive or delete older cards from this same detail screen.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var editFields: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Sound shape", selection: $draft.soundShape) {
                    ForEach(SoundShape.allCases) { shape in
                        Text(shape.displayName).tag(shape)
                    }
                }
                .accessibilityLabel("Sound shape")

                Picker("Direction", selection: $draft.direction) {
                    ForEach(ListenDirection.allCases) { direction in
                        Text(direction.displayName).tag(direction)
                    }
                }
                .accessibilityLabel("Direction")

                Picker("Weather", selection: $draft.weather) {
                    ForEach(WeatherTag.allCases) { weather in
                        Text(weather.displayName).tag(weather)
                    }
                }
                .accessibilityLabel("Weather")

                Picker("Mood", selection: $draft.mood) {
                    ForEach(MoodTag.allCases) { mood in
                        Text(mood.displayName).tag(mood)
                    }
                }
                .accessibilityLabel("Mood")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Private note")
                        .font(.headline)
                    TextEditor(text: $draft.note)
                        .frame(minHeight: 112)
                        .padding(8)
                        .background(Color.white.opacity(0.42), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .accessibilityLabel("Private note, optional and stored on this device")
                    HStack {
                        Text("Optional • \(draft.note.count)/240")
                            .font(.caption)
                            .foregroundStyle(draft.note.count > 240 ? .red : .secondary)
                        Spacer()
                        Button("Fill sample note") {
                            draft.note = "Heard a bright rhythm from the east window before breakfast."
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }

    private var actions: some View {
        GlassSurface {
            VStack(spacing: 12) {
                Button(action: saveCard) {
                    Label("Save Listen Card", systemImage: "tray.and.arrow.down.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Simulate Save Failure", action: simulateSaveFailure)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .accessibilityHint("Shows the local save error recovery copy")

                if currentCardID != nil {
                    HStack {
                        Button("Archive Card", action: archiveCard)
                            .buttonStyle(.bordered)
                        Button("Delete Card", role: .destructive, action: deleteCard)
                            .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button("Open Neighborhood Sound Map") {
                    selectedTab = .map
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(red: 0.55, green: 0.22, blue: 0.13))
            }
        }
    }

    private func savedBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
            Text(message)
                .font(.subheadline.weight(.semibold))
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func saveCard() {
        do {
            let id = currentCardID ?? UUID()
            let heardAt = originalHeardAt ?? Date()
            let card = draft.makeCard(id: id, heardAt: heardAt)
            try listenStore.save(card)
            currentCardID = id
            originalHeardAt = heardAt
            errorMessage = nil
            savedMessage = "Saved. This card will reappear after reopening the app."
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }

    private func simulateSaveFailure() {
        listenStore.simulateNextSaveFailure = true
        saveCard()
    }

    private func archiveCard() {
        guard let currentCardID else { return }
        do {
            try listenStore.archive(id: currentCardID)
            errorMessage = nil
            savedMessage = "Archived. You can still review it from the sound map archive section."
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }

    private func deleteCard() {
        guard let currentCardID else { return }
        do {
            try listenStore.delete(id: currentCardID)
            self.currentCardID = nil
            originalHeardAt = nil
            errorMessage = nil
            savedMessage = "Deleted. Start another listen whenever the window gets lively."
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }
}
