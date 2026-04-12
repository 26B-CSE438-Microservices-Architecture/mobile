import Foundation
import Combine

final class CartViewModel: ObservableObject {
    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var cartVendorName: String?
    @Published private(set) var selectedAddressTitle: String = ""
    @Published private(set) var cartSubtotal: Double = 0
    @Published private(set) var cartDeliveryFee: Double = 0
    @Published private(set) var cartServiceFee: Double = 0
    @Published private(set) var cartDiscount: Double = 0
    @Published private(set) var cartTotal: Double = 0

    func sync(from source: ContentViewModel) {
        cartItems = source.cartItems
        cartVendorName = source.cartVendorName
        selectedAddressTitle = source.selectedAddress.title
        cartSubtotal = source.cartSubtotal
        cartDeliveryFee = source.cartDeliveryFee
        cartServiceFee = source.cartServiceFee
        cartDiscount = source.cartDiscount
        cartTotal = source.cartTotal
    }
}
