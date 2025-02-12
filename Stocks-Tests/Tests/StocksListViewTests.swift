@testable import Stocks
@testable import StocksCore
@testable import StocksLogger
import Testing
import SnapshotTesting
import SwiftUI

@MainActor
final class StocksListViewTests {
    typealias MockViewModel = StocksListViewViewModel.Mock

    init() {
        Instantiator.mocking.withLock { $0 = .enabled(required: true) }
        ConsoleLogger.isTesting = true
    }

    @Test
    func loadingData() async {
        let viewModel = MockViewModel.loading()
        let view = StocksListView(viewModel: viewModel)
        let viewController =  UIHostingController(rootView: view)
        viewController.forceRender()

        await Task.yield()

        assertSnapshot(
            of: viewController,
            as: .image,
            named: #function,
            testName: "Should show loading state"
        )
    }

    @Test
    func loadedData() {
        let viewModel = MockViewModel.loaded()
        let view = StocksListView(viewModel: viewModel)
        let viewController =  UIHostingController(rootView: view)
        viewController.forceRender()

        assertSnapshot(
            of: viewController,
            as: .image,
            named: #function,
            testName: "Should show loaded items"
        )
    }

    @Test
    func loadNext() async {
        let viewModel = MockViewModel.loadNext()
        let view = StocksListView(viewModel: viewModel)
        let viewController =  UIHostingController(rootView: view)
        viewController.forceRender()
        
        await Task.yield()

        assertSnapshot(
            of: viewController,
            as: .image,
            named: #function,
            testName: "Should show loading next"
        )
    }

    @Test
    func showContentUnavalabile() async {
        let viewModel = MockViewModel.contentUnavailable()
        let view = StocksListView(viewModel: viewModel)
        let viewController =  UIHostingController(rootView: view)
        
        assertSnapshot(
            of: viewController,
            as: .image,
            named: #function,
            testName: "Should show unavailable content"
        )
    }
}
