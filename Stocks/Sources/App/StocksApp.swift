import SwiftUI

@main
struct StocksApp: App {
  private var isProduction: Bool {
    NSClassFromString("XCTestCase") == nil
  }

  var body: some Scene {
    WindowGroup {
      // TODO: Need some sort of navigation such as Coordinators.
      // Should also think about deep links.
      if isProduction {
        StocksListView(viewModel: StocksListViewModel())
      }
    }
  }
}
