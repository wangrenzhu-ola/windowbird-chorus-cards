import SwiftUI
import UIKit

struct WindowListenDetailView: View {
    @Environment(ListenStore.self) private var listenStore
    @Environment(ChorusCreditStore.self) private var creditStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: AppTab
    @State private var draft: ListenDraft
    @State private var currentCardID: UUID?
    @State private var originalHeardAt: Date?
    @State private var errorMessage: String?
    @State private var savedMessage: String?
    @State private var showSavedButtonState = false
    @FocusState private var isNoteFocused: Bool

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
                    creditSpendCard
                    if let errorMessage {
                        ErrorBanner(message: errorMessage)
                    }
                    if currentCardID == nil {
                        rhythmSummaryCard
                    }
                    WindowViewPhotoSection(
                        draft: $draft,
                        screenFraction: 0.58,
                        caption: "\(draft.soundShape.displayName) • \(draft.direction.displayName)"
                    )
                    if currentCardID != nil {
                        shapeEditSection
                    }
                    ListenMetadataFields(draft: $draft)
                    noteSection
                    actions
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Window Listen Detail")
        .toolbarTitleDisplayMode(.inline)
        .keyboardDismissToolbar(focus: $isNoteFocused)
    }

    private var creditSpendCard: some View {
        GlassSurface {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chorus Credits")
                        .font(.headline)
                    if currentCardID == nil {
                        Text("Save this new card for \(ChorusCreditStore.saveCost.formatted()) credits.")
                            .font(.subheadline)
                            .foregroundStyle(Color.wbMuted)
                    } else {
                        Text("Editing an existing card is free.")
                            .font(.subheadline)
                            .foregroundStyle(Color.wbMuted)
                    }
                }
                Spacer()
                ChorusCreditBalanceBadge(balance: creditStore.balance)
            }
        }
    }

    private var detailHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentCardID == nil ? "Create a private listen card" : "Edit listen card")
                .font(.title.bold())
                .foregroundStyle(Color.wbText)
            Text("Editing state is local until you save. Archive or delete older cards from this same detail screen.")
                .font(.body)
                .foregroundStyle(Color.wbMuted)
        }
    }

    private var rhythmSummaryCard: some View {
        let card = BirdMoodCard.all.first { $0.shape == draft.soundShape } ?? BirdMoodCard.all[0]
        return BirdSilhouetteCard(shape: card.shape, title: card.shape.displayName, subtitle: card.tip)
    }

    private var shapeEditSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sound shape")
                    .font(.headline)
                Picker("Sound shape", selection: $draft.soundShape) {
                    ForEach(SoundShape.allCases) { shape in
                        Text(shape.displayName).tag(shape)
                    }
                }
                .accessibilityLabel("Sound shape")
            }
        }
    }

    private var noteSection: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text("Private note")
                    .font(.headline)
                TextEditor(text: $draft.note)
                    .focused($isNoteFocused)
                    .frame(minHeight: 112)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(Color.wbText)
                    .background(Color.wbInk.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.wbCyan.opacity(0.30), lineWidth: 1)
                    }
                    .accessibilityLabel("Private note, optional and stored on this device")
                HStack {
                    Text("Optional • \(draft.note.count)/240")
                        .font(.caption)
                        .foregroundStyle(draft.note.count > 240 ? Color.wbAmber : Color.wbMuted)
                    Spacer()
                    #if DEBUG
                    Button("Fill sample note") {
                        draft.note = "Heard a bright rhythm from the east window before breakfast."
                    }
                    .font(.caption)
                    .foregroundStyle(Color.wbCyan)
                    #endif
                }
            }
        }
    }

    private var actions: some View {
        GlassSurface {
            VStack(spacing: 12) {
                Button(action: saveCard) {
                    if showSavedButtonState {
                        Label("Saved", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    } else {
                        if currentCardID == nil {
                            Label("Save Listen Card · \(ChorusCreditStore.saveCost) Credits", systemImage: "tray.and.arrow.down.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        } else {
                            Label("Save Changes", systemImage: "tray.and.arrow.down.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(showSavedButtonState ? Color.wbLime : Color.wbCyan)
                .disabled(draft.status == .archived)
                .accessibilityLabel(currentCardID == nil ? "Save Listen Card for \(ChorusCreditStore.saveCost) credits" : "Save Changes")

                if let savedMessage {
                    actionStatusBanner(
                        message: savedMessage,
                        systemImage: "checkmark.circle.fill",
                        tint: Color.wbLime
                    )
                } else if let errorMessage {
                    actionStatusBanner(
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle.fill",
                        tint: Color.wbAmber
                    )
                } else if draft.status == .archived {
                    Text("This listen card is archived. Reopen it from the archive list if you only want to review it.")
                        .font(.caption)
                        .foregroundStyle(Color.wbMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Tap save to keep this listen card on this device.")
                        .font(.caption)
                        .foregroundStyle(Color.wbMuted)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if currentCardID == nil && creditStore.balance < ChorusCreditStore.saveCost {
                    Button("Get Chorus Credits") {
                        dismissNoteKeyboard()
                        selectedTab = .shop
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.wbAmber)
                    .frame(maxWidth: .infinity)
                }

                #if DEBUG
                Button("Simulate Save Failure", action: simulateSaveFailure)
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .tint(Color.wbAmber)
                    .accessibilityHint("Shows the local save error recovery copy")
                #endif

                if currentCardID != nil {
                    HStack {
                        Button("Archive Card", action: archiveCard)
                            .buttonStyle(.bordered)
                            .tint(Color.wbCyan)
                        Button("Delete Card", role: .destructive, action: deleteCard)
                            .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                }

                Button("Open Neighborhood Sound Map") {
                    dismissNoteKeyboard()
                    selectedTab = .map
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.wbLime)
            }
        }
    }

    private func actionStatusBanner(message: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(message)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.wbText)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.wbPanelRaised.opacity(0.94), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.38), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func dismissNoteKeyboard() {
        isNoteFocused = false
    }

    private func saveCard() {
        dismissNoteKeyboard()
        showSavedButtonState = false
        do {
            if currentCardID == nil {
                try creditStore.spendForNewCardSave()
            }

            let id = currentCardID ?? UUID()
            let heardAt = originalHeardAt ?? Date()
            var card = draft.makeCard(id: id, heardAt: heardAt)
            card.status = draft.status

            if let pendingData = draft.pendingWindowPhotoData {
                if let oldFilename = card.windowPhotoFilename {
                    WindowPhotoStore.delete(filename: oldFilename)
                }
                let filename = try listenStore.persistWindowPhoto(data: pendingData, cardID: id)
                card.windowPhotoFilename = filename
                draft.windowPhotoFilename = filename
                draft.pendingWindowPhotoData = nil
            }

            try listenStore.save(card)
            currentCardID = id
            originalHeardAt = heardAt
            errorMessage = nil
            savedMessage = "Saved. This card will reappear after reopening the app. Balance: \(creditStore.balance.formatted()) credits."
            showTemporarySavedState()
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    private func simulateSaveFailure() {
        listenStore.simulateNextSaveFailure = true
        saveCard()
    }

    private func archiveCard() {
        dismissNoteKeyboard()
        guard let currentCardID else { return }
        do {
            try listenStore.archive(id: currentCardID)
            draft.status = .archived
            errorMessage = nil
            savedMessage = "Archived. You can still review it from the sound map archive section."
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            savedMessage = nil
        }
    }

    private func deleteCard() {
        dismissNoteKeyboard()
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

    private func showTemporarySavedState() {
        showSavedButtonState = true
        Task {
            try? await Task.sleep(for: .seconds(1.6))
            await MainActor.run {
                showSavedButtonState = false
            }
        }
    }
}
