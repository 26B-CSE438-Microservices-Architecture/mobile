import Foundation
import Combine

final class TabRouterViewModel: ObservableObject {
    @Published var selectedTab: AppTab = .home

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
}
