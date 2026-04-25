import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    let appVersionText: String = "v1.2.31 (191)"
    let menuItems: [AccountMenuItem] = AccountMenuItem.items
}
