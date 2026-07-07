import SwiftUI
import WebKit

struct LegalWebView: UIViewRepresentable {
    let document: LegalDocument
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, errorMessage: $errorMessage)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.lastRequestedDocument != document else { return }
        context.coordinator.lastRequestedDocument = document
        isLoading = true
        errorMessage = nil
        webView.loadHTMLString(document.htmlContent, baseURL: document.url.deletingLastPathComponent())
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var errorMessage: String?
        var lastRequestedDocument: LegalDocument?

        init(isLoading: Binding<Bool>, errorMessage: Binding<String?>) {
            _isLoading = isLoading
            _errorMessage = errorMessage
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            errorMessage = "This legal page could not be loaded yet. Replace the template URL in AppCopy when the final link is ready."
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            errorMessage = "This legal page could not be loaded yet. Replace the template URL in AppCopy when the final link is ready."
        }
    }
}

struct LegalDocumentView: View {
    let document: LegalDocument
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            DawnGradientBackground()
            VStack(spacing: 0) {
                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                        .padding(20)
                }
                LegalWebView(document: document, isLoading: $isLoading, errorMessage: $errorMessage)
                    .overlay {
                        if isLoading && errorMessage == nil {
                            ProgressView("Loading \(document.title)...")
                                .tint(Color.wbCyan)
                                .foregroundStyle(Color.wbText)
                        }
                    }
            }
        }
        .navigationTitle(document.title)
        .toolbarTitleDisplayMode(.inline)
    }
}

struct LegalLinksSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(LegalDocument.allCases) { document in
                NavigationLink {
                    LegalDocumentView(document: document)
                } label: {
                    Label(document.title, systemImage: iconName(for: document))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(Color.wbCyan)
                .accessibilityLabel("Open \(document.title)")
            }
        }
    }

    private func iconName(for document: LegalDocument) -> String {
        switch document {
        case .privacyPolicy: "hand.raised.fill"
        case .userAgreement: "doc.text.fill"
        }
    }
}
