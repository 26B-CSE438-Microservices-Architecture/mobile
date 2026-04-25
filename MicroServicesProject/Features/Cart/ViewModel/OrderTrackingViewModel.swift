import Foundation
import Combine

final class OrderTrackingViewModel: ObservableObject {
    @Published private(set) var order: Order

    init(order: Order) {
        self.order = order
    }
}
