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
}
