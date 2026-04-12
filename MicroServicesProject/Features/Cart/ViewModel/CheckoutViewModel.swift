import Foundation
import Combine

final class CheckoutViewModel: ObservableObject {
    func confirmOrder(using source: ContentViewModel) {
        source.placeOrder()
    }
}
