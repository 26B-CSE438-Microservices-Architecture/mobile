import Foundation
import Combine

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var resultVendors: [Vendor] = []
    @Published private(set) var resultProducts: [SearchProductResponse] = []
    @Published private(set) var errorMessage: String?

    @Published private(set) var discoverySuggestions: [String] = ["Burger", "Döner", "Market", "Protein bowl"]
    private let client = SearchAPIClient()
    private let fallbackLatitude = 36.8969
    private let fallbackLongitude = 30.7133

    var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasResults: Bool {
        !resultVendors.isEmpty || !resultProducts.isEmpty
    }

    func clearQuery() {
        query = ""
        resultVendors = []
        resultProducts = []
        errorMessage = nil
    }

    @MainActor
    func loadDiscoverySuggestionsIfNeeded() async {
        guard discoverySuggestions.count <= 4 else { return }
        do {
            let response = try await client.discovery()
            let suggestions = (response.suggestions ?? [])
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !suggestions.isEmpty {
                discoverySuggestions = suggestions
            }
        } catch {
            // Keep defaults if discovery endpoint fails.
        }
    }

    @MainActor
    func search(selectedAddress: Address?) async {
        let trimmedQuery = normalizedQuery
        guard !trimmedQuery.isEmpty else {
            resultVendors = []
            resultProducts = []
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let latitude = selectedAddress?.latitude ?? fallbackLatitude
        let longitude = selectedAddress?.longitude ?? fallbackLongitude

        do {
            let response = try await client.search(
                query: trimmedQuery,
                latitude: latitude,
                longitude: longitude
            )
            resultVendors = response.vendors.map(\.appVendor)
            resultProducts = response.products
        } catch {
            resultVendors = []
            resultProducts = []
            errorMessage = error.localizedDescription
        }
    }
}
