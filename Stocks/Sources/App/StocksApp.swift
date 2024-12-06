import SwiftUI

@main
struct StocksApp: App {
  var body: some Scene {
    WindowGroup {
      StocksListView(viewModel: StocksListViewModel())
    }
  }
}
