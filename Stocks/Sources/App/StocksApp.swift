import SwiftUI

@main
struct StocksApp: App {
  var body: some Scene {
    WindowGroup {
      // TODO: Need some sort of navigation such as Coordinators.
      // Should also think about deep links.
      StocksListView(viewModel: StocksListViewModel())
    }
  }
}
