import Foundation
import Combine

final class OrdersViewModel: ObservableObject {
    @Published var selectedScope: VendorKind = .restaurant
    @Published var searchText: String = ""

    func filteredOrders(from orders: [Order]) -> [Order] {
        let categoryFiltered = orders.filter { order in
            switch selectedScope {
            case .market:
                return order.kind == .market
            default:
                return order.kind != .market
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return categoryFiltered }

        return categoryFiltered.filter { order in
            order.vendorName.localizedCaseInsensitiveContains(query) ||
            (order.itemSummary ?? "").localizedCaseInsensitiveContains(query)
        }
    }
}
