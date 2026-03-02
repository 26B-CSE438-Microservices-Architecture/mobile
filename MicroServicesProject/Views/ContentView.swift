import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(viewModel.greetingText)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
