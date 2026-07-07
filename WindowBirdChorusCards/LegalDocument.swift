import Foundation

enum LegalDocument: String, Identifiable, CaseIterable {
    case privacyPolicy
    case userAgreement

    var id: String { rawValue }

    var title: String {
        switch self {
        case .privacyPolicy: AppCopy.privacyPolicyTitle
        case .userAgreement: AppCopy.userAgreementTitle
        }
    }

    var url: URL {
        switch self {
        case .privacyPolicy: AppCopy.privacyPolicyURL
        case .userAgreement: AppCopy.userAgreementURL
        }
    }

    var htmlContent: String {
        switch self {
        case .privacyPolicy:
            """
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
            body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #071314; color: #E6FAF0; padding: 20px; line-height: 1.55; }
            h1, h2 { color: #26EDD1; }
            a { color: #C7F56F; }
            .card { background: rgba(12, 29, 31, 0.92); border: 1px solid rgba(38, 237, 209, 0.30); border-radius: 16px; padding: 16px; margin-bottom: 16px; }
            </style>
            </head>
            <body>
            <h1>Privacy Policy</h1>
            <div class="card">
            <p>WindowBird Chorus Cards stores your listen cards, notes, and optional window view photos on this device.</p>
            <p>The core listening flow does not upload your private listen data to a WindowBird server.</p>
            <p>Credit purchases are handled by Apple using StoreKit. WindowBird does not receive your full payment details.</p>
            </div>
            <div class="card">
            <h2>What you save</h2>
            <p>Each listen card may include a sound shape, direction, weather, mood, private note, and optional window photo. This data is kept in local app storage so it can reappear after reopening the app.</p>
            <h2>Photos and camera</h2>
            <p>If you choose a photo from your library or capture a new one, the selected image is stored locally with the card. Exporting a window photo back to Photos happens only when you tap the export action.</p>
            <h2>Permissions</h2>
            <p>Photo library, camera, and tracking prompts are requested only when the related app feature needs them. The main listening flow does not require microphone recording.</p>
            </div>
            <p>Reference link: <a href="\(url.absoluteString)">\(url.absoluteString)</a></p>
            </body>
            </html>
            """
        case .userAgreement:
            """
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
            body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; background: #071314; color: #E6FAF0; padding: 20px; line-height: 1.55; }
            h1, h2 { color: #26EDD1; }
            a { color: #C7F56F; }
            .card { background: rgba(12, 29, 31, 0.92); border: 1px solid rgba(38, 237, 209, 0.30); border-radius: 16px; padding: 16px; margin-bottom: 16px; }
            </style>
            </head>
            <body>
            <h1>User Agreement</h1>
            <div class="card">
            <p>WindowBird Chorus Cards is a private journaling tool for lightweight birdsong observation.</p>
            <p>You are responsible for the notes and photos you choose to save on your device.</p>
            <p>The app is provided for personal use and may change as the product evolves.</p>
            </div>
            <div class="card">
            <h2>Using the app</h2>
            <p>You can create, edit, archive, and delete listen cards. Deleting a card removes its local data from the app.</p>
            <h2>Credits</h2>
            <p>Saving a new card may require Chorus Credits. Editing an existing card is free. Credit balances are local to this app experience and are not restored as a subscription benefit.</p>
            <h2>Availability</h2>
            <p>WindowBird may revise features, wording, or visual presentation without notice while the app remains in development.</p>
            </div>
            <p>Reference link: <a href="\(url.absoluteString)">\(url.absoluteString)</a></p>
            </body>
            </html>
            """
        }
    }
}
