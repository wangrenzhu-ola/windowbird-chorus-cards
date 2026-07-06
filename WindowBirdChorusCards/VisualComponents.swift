import SwiftUI

struct DawnGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.75, blue: 0.55),
                Color(red: 0.98, green: 0.90, blue: 0.72),
                Color(red: 0.76, green: 0.86, blue: 0.84)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.32))
                .frame(width: 220, height: 220)
                .blur(radius: 8)
                .offset(x: 70, y: -60)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color(red: 0.45, green: 0.58, blue: 0.52).opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 18)
                .offset(x: -90, y: 100)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
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
        if #available(iOS 26.0, *) {
            content
                .padding(16)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: radius))
        } else {
            content
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
        }
    }
}

struct BirdSilhouetteCard: View {
    let shape: SoundShape
    let title: String
    let subtitle: String

    var body: some View {
        GlassSurface(radius: 28) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.20, green: 0.29, blue: 0.25).opacity(0.12))
                    BirdSilhouette()
                        .fill(Color(red: 0.17, green: 0.25, blue: 0.22))
                        .padding(14)
                    Text(shape.shortGlyph)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .offset(y: 23)
                }
                .frame(width: 74, height: 74)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.16, green: 0.20, blue: 0.18))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                .strokeBorder(Color(red: 0.20, green: 0.30, blue: 0.26).opacity(0.30), lineWidth: 2)
            ForEach(ListenDirection.allCases) { marker in
                Text(String(marker.displayName.prefix(1)))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(marker == direction ? .primary : .secondary)
                    .offset(y: -58)
                    .rotationEffect(.degrees(marker.degrees))
                    .rotationEffect(.degrees(-marker.degrees))
            }
            Capsule()
                .fill(Color(red: 0.86, green: 0.37, blue: 0.22))
                .frame(width: 7, height: 58)
                .offset(y: -28)
                .rotationEffect(.degrees(direction.degrees))
                .shadow(color: .black.opacity(0.16), radius: 4, y: 2)
            Circle()
                .fill(Color(red: 0.18, green: 0.26, blue: 0.22))
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
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.18, green: 0.29, blue: 0.25).opacity(0.10))
                ForEach(cards.prefix(24)) { card in
                    SoundDot(card: card)
                        .position(position(for: card, in: proxy.size))
                }
                if cards.isEmpty {
                    VStack(spacing: 8) {
                        BirdSilhouette()
                            .stroke(Color.secondary.opacity(0.45), lineWidth: 2)
                            .frame(width: 56, height: 56)
                        Text("Your sound map is quiet for now.")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.secondary)
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

private struct SoundDot: View {
    let card: ListenCard

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay {
                    Text(card.soundShape.shortGlyph)
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(.white)
                }
            Text(card.direction.displayName.prefix(1))
                .font(.caption2.weight(.bold))
        }
        .accessibilityLabel("\(card.soundShape.displayName) from \(card.direction.displayName)")
    }

    private var color: Color {
        switch card.mood {
        case .curious: Color(red: 0.87, green: 0.39, blue: 0.25)
        case .calm: Color(red: 0.34, green: 0.55, blue: 0.49)
        case .bright: Color(red: 0.94, green: 0.63, blue: 0.26)
        case .sleepy: Color(red: 0.46, green: 0.49, blue: 0.66)
        }
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(red: 0.78, green: 0.24, blue: 0.16))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.35, green: 0.12, blue: 0.08))
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(red: 1.0, green: 0.89, blue: 0.82), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
