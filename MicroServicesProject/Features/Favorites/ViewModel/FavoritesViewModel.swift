import Foundation
import Combine

final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Vendor] = []

    func refresh(from vendors: [Vendor]) {
        favorites = vendors
    }
}
