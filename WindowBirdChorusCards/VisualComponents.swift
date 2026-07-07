import SwiftUI
import PhotosUI

extension Color {
    static let wbInk = Color(red: 0.02, green: 0.05, blue: 0.06)
    static let wbPanel = Color(red: 0.04, green: 0.10, blue: 0.11)
    static let wbPanelRaised = Color(red: 0.07, green: 0.15, blue: 0.15)
    static let wbCyan = Color(red: 0.15, green: 0.93, blue: 0.82)
    static let wbLime = Color(red: 0.78, green: 0.96, blue: 0.45)
    static let wbAmber = Color(red: 1.00, green: 0.62, blue: 0.22)
    static let wbText = Color(red: 0.90, green: 0.98, blue: 0.94)
    static let wbMuted = Color(red: 0.56, green: 0.70, blue: 0.66)
}

struct DawnGradientBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        .wbInk,
                        Color(red: 0.01, green: 0.13, blue: 0.15),
                        Color(red: 0.02, green: 0.20, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadarGrid()
                    .stroke(Color.wbCyan.opacity(0.10), lineWidth: 1)
                    .frame(width: proxy.size.width * 1.28, height: proxy.size.height * 1.02)
                    .rotationEffect(.degrees(-8))
                    .offset(x: proxy.size.width * 0.07, y: proxy.size.height * 0.08)

                Circle()
                    .stroke(Color.wbCyan.opacity(0.18), lineWidth: 2)
                    .frame(width: proxy.size.width * 0.86, height: proxy.size.width * 0.86)
                    .offset(x: proxy.size.width * 0.34, y: -proxy.size.height * 0.18)

                Circle()
                    .fill(Color.wbCyan.opacity(0.10))
                    .frame(width: proxy.size.width * 0.66, height: proxy.size.width * 0.66)
                    .blur(radius: 40)
                    .offset(x: -proxy.size.width * 0.30, y: proxy.size.height * 0.30)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color.wbAmber.opacity(0.10)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

private struct RadarGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 34
        var x = rect.minX
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }
        var y = rect.minY
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += step
        }
        return path
    }
}

struct GlassSurface<Content: View>: View {
    let radius: CGFloat
    let content: Content

    init(radius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.radius = radius
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .foregroundStyle(Color.wbText)
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: radius,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: radius,
                    topTrailingRadius: 8,
                    style: .continuous
                )
                .fill(Color.wbPanel.opacity(0.92))
                .overlay {
                    UnevenRoundedRectangle(
                        topLeadingRadius: radius,
                        bottomLeadingRadius: 8,
                        bottomTrailingRadius: radius,
                        topTrailingRadius: 8,
                        style: .continuous
                    )
                    .stroke(Color.wbCyan.opacity(0.30), lineWidth: 1)
                }
                .shadow(color: Color.wbCyan.opacity(0.12), radius: 18, y: 10)
            }
    }
}

struct BirdSilhouetteCard: View {
    let shape: SoundShape
    let title: String
    let subtitle: String

    var body: some View {
        GlassSurface(radius: 20) {
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
                    Text(title)
                        .font(.headline.weight(.black))
                        .foregroundStyle(Color.wbText)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.wbMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Illustrated bird silhouette card for \(title)")
    }
}

struct BirdSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addEllipse(in: CGRect(x: w * 0.30, y: h * 0.30, width: w * 0.42, height: h * 0.34))
        path.addEllipse(in: CGRect(x: w * 0.58, y: h * 0.22, width: w * 0.22, height: h * 0.22))
        path.move(to: CGPoint(x: w * 0.77, y: h * 0.34))
        path.addLine(to: CGPoint(x: w * 0.96, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.77, y: h * 0.46))
        path.closeSubpath()
        path.move(to: CGPoint(x: w * 0.40, y: h * 0.61))
        path.addLine(to: CGPoint(x: w * 0.32, y: h * 0.84))
        path.move(to: CGPoint(x: w * 0.55, y: h * 0.61))
        path.addLine(to: CGPoint(x: w * 0.61, y: h * 0.84))
        path.move(to: CGPoint(x: w * 0.29, y: h * 0.42))
        path.addCurve(
            to: CGPoint(x: w * 0.06, y: h * 0.24),
            control1: CGPoint(x: w * 0.20, y: h * 0.35),
            control2: CGPoint(x: w * 0.14, y: h * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.26, y: h * 0.57),
            control1: CGPoint(x: w * 0.10, y: h * 0.43),
            control2: CGPoint(x: w * 0.16, y: h * 0.53)
        )
        return path
    }
}

struct DirectionRing: View {
    let direction: ListenDirection

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.wbInk.opacity(0.72))
            ForEach([38, 72, 106], id: \.self) { size in
                Circle()
                    .stroke(Color.wbCyan.opacity(0.20), style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                    .frame(width: CGFloat(size), height: CGFloat(size))
            }
            Circle()
                .strokeBorder(Color.wbCyan.opacity(0.55), lineWidth: 2)
            ForEach(ListenDirection.allCases) { marker in
                Text(String(marker.displayName.prefix(1)))
                    .font(.caption2.weight(.bold).monospaced())
                    .foregroundStyle(marker == direction ? Color.wbLime : Color.wbMuted)
                    .offset(y: -58)
                    .rotationEffect(.degrees(marker.degrees))
                    .rotationEffect(.degrees(-marker.degrees))
            }
            Capsule()
                .fill(Color.wbLime)
                .frame(width: 5, height: 58)
                .offset(y: -28)
                .rotationEffect(.degrees(direction.degrees))
                .shadow(color: Color.wbLime.opacity(0.7), radius: 8)
            Circle()
                .fill(Color.wbCyan)
                .frame(width: 12, height: 12)
        }
        .frame(width: 142, height: 142)
        .accessibilityLabel("Compass direction ring set to \(direction.displayName)")
    }
}

struct NeighborhoodSoundDots: View {
    let cards: [ListenCard]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 28, bottomLeadingRadius: 8, bottomTrailingRadius: 28, topTrailingRadius: 8)
                    .fill(Color.wbInk.opacity(0.82))
                    .overlay {
                        RadarMapGrid()
                            .stroke(Color.wbCyan.opacity(0.16), lineWidth: 1)
                            .padding(18)
                    }
                    .overlay {
                        UnevenRoundedRectangle(topLeadingRadius: 28, bottomLeadingRadius: 8, bottomTrailingRadius: 28, topTrailingRadius: 8)
                            .stroke(Color.wbCyan.opacity(0.38), lineWidth: 1)
                    }
                ForEach(cards.prefix(24)) { card in
                    SoundDot(card: card)
                        .position(position(for: card, in: proxy.size))
                }
                if cards.isEmpty {
                    VStack(spacing: 8) {
                        BirdSilhouette()
                            .stroke(Color.wbCyan.opacity(0.55), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        Text("Your sound map is quiet for now.")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Color.wbMuted)
                    .multilineTextAlignment(.center)
                }
            }
        }
        .frame(height: 240)
        .accessibilityLabel("Neighborhood sound dots map with \(cards.count) saved listen cards")
    }

    private func position(for card: ListenCard, in size: CGSize) -> CGPoint {
        let angle = (card.direction.degrees - 90) * .pi / 180
        let index = cards.firstIndex(where: { $0.id == card.id }) ?? 0
        let ring = CGFloat(0.22 + (Double(index % 4) * 0.12))
        let radius = min(size.width, size.height) * ring
        return CGPoint(
            x: size.width / 2 + cos(angle) * radius,
            y: size.height / 2 + sin(angle) * radius
        )
    }
}

private struct RadarMapGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        for radius in stride(from: min(rect.width, rect.height) * 0.18, through: min(rect.width, rect.height) * 0.46, by: 34) {
            path.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        }
        for angle in stride(from: 0.0, to: 360.0, by: 45.0) {
            let radians = angle * .pi / 180
            let length = min(rect.width, rect.height) * 0.48
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + cos(radians) * length, y: center.y + sin(radians) * length))
        }
        return path
    }
}

private struct SoundDot: View {
    let card: ListenCard

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .shadow(color: color.opacity(0.8), radius: 8)
                .overlay {
                    Text(card.soundShape.shortGlyph)
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(Color.wbInk)
                }
            Text(card.direction.displayName.prefix(1))
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.wbText)
        }
        .accessibilityLabel("\(card.soundShape.displayName) from \(card.direction.displayName)")
    }

    private var color: Color {
        switch card.mood {
        case .curious: Color.wbCyan
        case .calm: Color.wbLime
        case .bright: Color.wbAmber
        case .sleepy: Color(red: 0.52, green: 0.66, blue: 1.0)
        }
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.wbAmber)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.wbText)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(red: 0.28, green: 0.09, blue: 0.08).opacity(0.92), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.wbAmber.opacity(0.45), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

// MARK: - Window view photos (user-uploaded)

struct WindowViewPhotoHero: View {
    let uiImage: UIImage?
    var screenFraction: CGFloat = 0.55
    var caption: String?

    private var heroHeight: CGFloat {
        min(UIScreen.main.bounds.height * screenFraction, 320)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Group {
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: heroHeight)
                        .background(Color.wbInk.opacity(0.82))
                        .overlay(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [.clear, Color.wbInk.opacity(0.72)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: min(heroHeight * 0.38, 120))
                        }
                        .overlay(alignment: .bottomLeading) {
                            if let caption {
                                Text(caption)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.wbText)
                                    .padding(16)
                            }
                        }
                } else {
                    ZStack {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 28,
                            bottomLeadingRadius: 8,
                            bottomTrailingRadius: 28,
                            topTrailingRadius: 8,
                            style: .continuous
                        )
                        .fill(Color.wbInk.opacity(0.82))
                        .overlay {
                            UnevenRoundedRectangle(
                                topLeadingRadius: 28,
                                bottomLeadingRadius: 8,
                                bottomTrailingRadius: 28,
                                topTrailingRadius: 8,
                                style: .continuous
                            )
                            .stroke(Color.wbCyan.opacity(0.30), style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
                        }
                        VStack(spacing: 10) {
                            Image(systemName: "camera.viewfinder")
                                .font(.largeTitle)
                                .foregroundStyle(Color.wbCyan.opacity(0.72))
                            Text("No window view yet")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.wbMuted)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: heroHeight)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 8,
                    style: .continuous
                )
            )
            .overlay {
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 8,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 8,
                    style: .continuous
                )
                .stroke(Color.wbCyan.opacity(uiImage == nil ? 0.30 : 0.42), lineWidth: 1)
            }
            .shadow(color: Color.wbCyan.opacity(uiImage == nil ? 0.08 : 0.18), radius: 16, y: 8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(uiImage == nil ? "No window view photo" : "Window view photo, \(caption ?? "saved listen")")
    }
}

struct WindowViewPhotoSection: View {
    @Binding var draft: ListenDraft
    var screenFraction: CGFloat = 0.55
    var caption: String?

    @State private var selectedItem: PhotosPickerItem?
    @State private var displayedImage: UIImage?
    @State private var showCamera = false
    @State private var exportMessage: String?

    var body: some View {
        GlassSurface(radius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Window view", systemImage: "camera.viewfinder")
                    .font(.headline)
                Text("Optional photo of what you saw outside while listening. Stored privately on this device.")
                    .font(.subheadline)
                    .foregroundStyle(Color.wbMuted)

                WindowViewPhotoHero(uiImage: displayedImage, screenFraction: screenFraction, caption: caption)

                if let exportMessage {
                    Text(exportMessage)
                        .font(.caption)
                        .foregroundStyle(Color.wbLime)
                }

                HStack(spacing: 12) {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        Label(displayedImage == nil ? "Choose from Photos" : "Replace from Photos", systemImage: "photo.on.rectangle.angled")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.wbCyan)

                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showCamera = true
                        } label: {
                            Label("Capture Window View", systemImage: "camera.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.wbCyan)
                    }
                }

                if displayedImage != nil {
                    HStack(spacing: 12) {
                        Button {
                            Task { await exportDisplayedImage() }
                        } label: {
                            Label("Export Window View", systemImage: "square.and.arrow.down")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color.wbLime)
                        .accessibilityLabel("Export Window View to photo library")

                        Button("Remove", role: .destructive) {
                            removePhoto()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .onAppear(perform: refreshDisplayedImage)
        .onChange(of: selectedItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        applyPickedImage(image, data: data)
                    }
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker { image in
                let data = image.jpegData(compressionQuality: 0.88) ?? image.pngData() ?? Data()
                applyPickedImage(image, data: data)
            }
            .ignoresSafeArea()
        }
    }

    private func applyPickedImage(_ image: UIImage, data: Data) {
        draft.pendingWindowPhotoData = data
        draft.windowPhotoFilename = nil
        displayedImage = image
        exportMessage = nil
    }

    private func refreshDisplayedImage() {
        if let data = draft.pendingWindowPhotoData, let image = UIImage(data: data) {
            displayedImage = image
            return
        }
        if let filename = draft.windowPhotoFilename {
            displayedImage = WindowPhotoStore.load(filename: filename)
            return
        }
        displayedImage = nil
    }

    private func removePhoto() {
        draft.pendingWindowPhotoData = nil
        draft.windowPhotoFilename = nil
        displayedImage = nil
        selectedItem = nil
        exportMessage = nil
    }

    private func exportDisplayedImage() async {
        guard let displayedImage else { return }
        do {
            try await WindowPhotoLibraryExporter.export(displayedImage)
            exportMessage = "Exported to Photos. Your listen card still keeps a private copy on this device."
        } catch {
            exportMessage = error.localizedDescription
        }
    }
}

struct WindowViewPhotoReadOnly: View {
    let card: ListenCard
    var screenFraction: CGFloat = 0.50
    var caption: String?

    private var uiImage: UIImage? {
        guard let filename = card.windowPhotoFilename else { return nil }
        return WindowPhotoStore.load(filename: filename)
    }

    var body: some View {
        if uiImage != nil {
            WindowViewPhotoHero(
                uiImage: uiImage,
                screenFraction: screenFraction,
                caption: caption ?? "\(card.soundShape.displayName) • \(card.direction.displayName)"
            )
        }
    }
}

struct ChorusCreditBalanceBadge: View {
    let balance: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.hexagongrid.fill")
                .foregroundStyle(Color.wbLime)
            Text("\(balance.formatted()) Credits")
                .font(.subheadline.weight(.bold).monospacedDigit())
                .foregroundStyle(Color.wbText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.wbPanelRaised.opacity(0.94), in: Capsule())
        .overlay {
            Capsule()
                .stroke(Color.wbLime.opacity(0.42), lineWidth: 1)
        }
        .accessibilityLabel("Chorus credit balance \(balance)")
    }
}

struct ChorusCreditPackCard: View {
    let item: IAPCatalogItem
    let displayPrice: String
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        GlassSurface(radius: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(item.creditTitle)
                        .font(.headline)
                        .foregroundStyle(Color.wbText)
                    Spacer(minLength: 8)
                    if item.isPromotion {
                        Text("Limited Offer")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(Color.wbInk)
                            .background(Color.wbAmber, in: Capsule())
                    }
                }
                Text("Adds credits for saving new private listen cards.")
                    .font(.caption)
                    .foregroundStyle(Color.wbMuted)
                Button(action: onPurchase) {
                    HStack {
                        Text(displayPrice)
                            .font(.subheadline.weight(.bold))
                        Spacer()
                        Text(isPurchasing ? "Purchasing..." : "Buy Credits")
                            .font(.caption.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(item.isPromotion ? Color.wbAmber : Color.wbCyan)
                .disabled(isPurchasing)
                .accessibilityLabel("Buy \(item.creditTitle) for \(displayPrice)")
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        }
    }
}

extension View {
    func keyboardDismissToolbar(focus: FocusState<Bool>.Binding) -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focus.wrappedValue = false
                }
                .fontWeight(.semibold)
                .foregroundStyle(Color.wbCyan)
                .accessibilityLabel("Dismiss keyboard")
            }
        }
    }
}
