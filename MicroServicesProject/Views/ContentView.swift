import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    @StateObject private var tabRouter = TabRouterViewModel()

    init() {
        let repository = MockAppRepository()
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }

    var body: some View {
        TrendyolGoPrototypeView()
            .environmentObject(viewModel)
            .environmentObject(tabRouter)
            .onAppear {
                viewModel.onTabChange = { tab in
                    tabRouter.selectTab(tab)
                }
            }
    }
}

#Preview {
    ContentView()
}
