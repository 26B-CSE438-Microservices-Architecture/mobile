import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        TrendyolGoPrototypeView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
