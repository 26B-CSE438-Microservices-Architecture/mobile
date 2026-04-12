import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""

    let recentSearches = ["Burger", "Döner", "Market", "Protein bowl"]

    func clearQuery() {
        query = ""
    }

    func results(in vendors: [Vendor]) -> [Vendor] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return [] }

        return vendors.filter { vendor in
            vendor.name.localizedCaseInsensitiveContains(term) ||
            vendor.summary.localizedCaseInsensitiveContains(term) ||
            vendor.tags.contains(where: { $0.localizedCaseInsensitiveContains(term) }) ||
            vendor.menuSections.contains { section in
                section.products.contains { product in
                    product.name.localizedCaseInsensitiveContains(term) ||
                    product.description.localizedCaseInsensitiveContains(term)
                }
            }
        }
    }
}
