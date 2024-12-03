import SwiftUI

@main
struct StocksApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        StocksListView(viewModel: StocksListViewModel())
      }
    }
  }
}
