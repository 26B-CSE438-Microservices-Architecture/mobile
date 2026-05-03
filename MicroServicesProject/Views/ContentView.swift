import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel
    @StateObject private var authSession = AuthSessionViewModel()
    @StateObject private var tabRouter = TabRouterViewModel()

    init() {
        let repository = MockAppRepository()
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }

    var body: some View {
        Group {
            if authSession.isRestoringSession {
                ProgressView("Oturum kontrol ediliyor")
                    .tint(AppTheme.orange)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.canvas.ignoresSafeArea())
            } else {
                TrendyolGoPrototypeView()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(tabRouter)
        .environmentObject(authSession)
        .onAppear {
            viewModel.onTabChange = { tab in
                tabRouter.selectTab(tab)
            }
            Task {
                await viewModel.loadRemoteRestaurants()
                if let accessToken = authSession.accessToken {
                    await viewModel.loadHomeDiscover(accessToken: accessToken)
                    await viewModel.loadFavorites(accessToken: accessToken)
                    await viewModel.loadOrders(accessToken: accessToken)
                }
            }
        }
        .onReceive(authSession.$userProfile) { profile in
            if let profile {
                viewModel.applyRemoteUserProfile(profile)
                if let accessToken = authSession.accessToken {
                    Task {
                        await viewModel.loadHomeDiscover(accessToken: accessToken)
                        await viewModel.loadFavorites(accessToken: accessToken)
                        await viewModel.loadOrders(accessToken: accessToken)
                    }
                }
            } else {
                viewModel.resetUserProfileToRepository()
            }
        }
    }
}

#Preview {
    ContentView()
}
