import Foundation

struct IAPCatalogItem: Identifiable, Equatable, Hashable {
    let productID: String
    let creditAmount: Int
    let referencePriceUSD: String
    let isPromotion: Bool

    var id: String { productID }

    var creditTitle: String {
        "\(creditAmount.formatted()) Chorus Credits"
    }
}

enum IAPProductCatalog {
    static let initialBalance = 100
    static let saveCost = 10
    static let productCount = 27
    static let standardProductCount = 19
    static let promotionProductCount = 8

    static let all: [IAPCatalogItem] = [
        IAPCatalogItem(productID: "473900", creditAmount: 110, referencePriceUSD: "$0.99", isPromotion: false),
        IAPCatalogItem(productID: "473901", creditAmount: 210, referencePriceUSD: "$1.99", isPromotion: false),
        IAPCatalogItem(productID: "473902", creditAmount: 310, referencePriceUSD: "$2.99", isPromotion: false),
        IAPCatalogItem(productID: "473903", creditAmount: 400, referencePriceUSD: "$3.99", isPromotion: false),
        IAPCatalogItem(productID: "473904", creditAmount: 520, referencePriceUSD: "$4.99", isPromotion: false),
        IAPCatalogItem(productID: "473905", creditAmount: 630, referencePriceUSD: "$5.99", isPromotion: false),
        IAPCatalogItem(productID: "473906", creditAmount: 740, referencePriceUSD: "$6.99", isPromotion: false),
        IAPCatalogItem(productID: "473907", creditAmount: 1000, referencePriceUSD: "$8.99", isPromotion: false),
        IAPCatalogItem(productID: "473908", creditAmount: 1200, referencePriceUSD: "$9.99", isPromotion: false),
        IAPCatalogItem(productID: "473909", creditAmount: 1600, referencePriceUSD: "$12.99", isPromotion: false),
        IAPCatalogItem(productID: "473910", creditAmount: 2000, referencePriceUSD: "$15.99", isPromotion: false),
        IAPCatalogItem(productID: "473911", creditAmount: 2600, referencePriceUSD: "$19.99", isPromotion: false),
        IAPCatalogItem(productID: "473912", creditAmount: 3300, referencePriceUSD: "$24.99", isPromotion: false),
        IAPCatalogItem(productID: "473913", creditAmount: 4200, referencePriceUSD: "$29.99", isPromotion: false),
        IAPCatalogItem(productID: "473914", creditAmount: 4900, referencePriceUSD: "$34.99", isPromotion: false),
        IAPCatalogItem(productID: "473915", creditAmount: 6000, referencePriceUSD: "$39.99", isPromotion: false),
        IAPCatalogItem(productID: "473916", creditAmount: 8000, referencePriceUSD: "$49.99", isPromotion: false),
        IAPCatalogItem(productID: "473917", creditAmount: 14000, referencePriceUSD: "$79.99", isPromotion: false),
        IAPCatalogItem(productID: "473918", creditAmount: 14998, referencePriceUSD: "$99.99", isPromotion: false),
        IAPCatalogItem(productID: "473919", creditAmount: 520, referencePriceUSD: "$1.99", isPromotion: true),
        IAPCatalogItem(productID: "473920", creditAmount: 800, referencePriceUSD: "$2.99", isPromotion: true),
        IAPCatalogItem(productID: "473921", creditAmount: 1300, referencePriceUSD: "$4.99", isPromotion: true),
        IAPCatalogItem(productID: "473922", creditAmount: 1500, referencePriceUSD: "$5.99", isPromotion: true),
        IAPCatalogItem(productID: "473923", creditAmount: 2700, referencePriceUSD: "$11.99", isPromotion: true),
        IAPCatalogItem(productID: "473924", creditAmount: 2900, referencePriceUSD: "$12.99", isPromotion: true),
        IAPCatalogItem(productID: "473925", creditAmount: 7200, referencePriceUSD: "$34.99", isPromotion: true),
        IAPCatalogItem(productID: "473926", creditAmount: 17000, referencePriceUSD: "$79.99", isPromotion: true)
    ]

    static let productIDs: Set<String> = Set(all.map(\.productID))

    static var standardProducts: [IAPCatalogItem] {
        all.filter { !$0.isPromotion }
    }

    static var promotionProducts: [IAPCatalogItem] {
        all.filter(\.isPromotion)
    }

    static func item(for productID: String) -> IAPCatalogItem? {
        all.first { $0.productID == productID }
    }

    static let featuredProductIDs: [String] = ["473919", "473920", "473904", "473907", "473910"]

    static var featuredProducts: [IAPCatalogItem] {
        featuredProductIDs.compactMap(item(for:))
    }

    static var additionalProducts: [IAPCatalogItem] {
        all.filter { !featuredProductIDs.contains($0.productID) }
    }
}
