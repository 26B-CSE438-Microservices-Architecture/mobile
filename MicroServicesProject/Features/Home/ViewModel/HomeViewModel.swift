import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var isSearchPresented: Bool = false
    @Published var isShowingAddressSelector: Bool = false
    @Published private(set) var searchSuggestionIndex: Int = 0

    let searchSuggestionTimer = Timer.publish(every: 2.8, on: .main, in: .common).autoconnect()

    func activeSearchSuggestion(from suggestions: [String]) -> String {
        guard !suggestions.isEmpty else { return "Döner ara" }
        return suggestions[searchSuggestionIndex % suggestions.count]
    }

    func advanceSuggestion(total: Int) {
        guard total > 0 else { return }
        searchSuggestionIndex = (searchSuggestionIndex + 1) % total
    }

    func openSearch() {
        isSearchPresented = true
    }

    func openAddressSelector() {
        isShowingAddressSelector = true
    }
}
