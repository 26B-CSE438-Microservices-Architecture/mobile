import SwiftUI

final class ContentViewModel: ObservableObject {
    @Published var greetingText: String = "Hello, world!"
}
