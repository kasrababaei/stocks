import Quick
import Nimble
import SnapshotTesting
import SwiftUI
@testable import Stocks

final class SignInViewSpec: AsyncSpec {
    static override func spec() {
        context("when the view appears") {
            it("should call loadData") { @MainActor in
                let viewModel = SignInViewViewModel.Mock()
                UIHostingController(rootView: SignInView(viewModel: viewModel))._render(seconds: 0)
                await Task.yield()
                expect(viewModel.loadDataCallCount) == 1
                expect(viewModel.wasLoadDataCalled) == true
            }
        }

        context("when in loading state") {
            it("should show a progress view") { @MainActor in
                let viewModel = SignInViewViewModel.Mock.loading
                let viewController = UIHostingController(rootView: SignInView(viewModel: viewModel))
                assertSnapshot(of: viewController, as: .image(on: .iPhone12), testName: "should show a progress view")
            }
        }

        context("when in loaded state") {
            it("should show a progress view") { @MainActor in
                let viewModel = SignInViewViewModel.Mock.loaded
                let viewController = UIHostingController(rootView: SignInView(viewModel: viewModel))
                assertSnapshot(of: viewController, as: .image(on: .iPhone12), testName: "should hide the progress view")
            }
        }

        context("when finished with error") {
            it("should show error message") { @MainActor in
                let viewModel = SignInViewViewModel.Mock.finishedWithError
                let viewController = UIHostingController(rootView: SignInView(viewModel: viewModel))
                assertSnapshot(of: viewController, as: .image(on: .iPhone12), testName: "should show error message")
            }
        }

        context("when logging in") {
            it("should show a progress view and disable buttons") { @MainActor in
                let viewModel = SignInViewViewModel.Mock.loggingIn
                let viewController = UIHostingController(rootView: SignInView(viewModel: viewModel))
                assertSnapshot(of: viewController, as: .image(on: .iPhone12), testName: "should show a progress view and disable buttons")
            }
        }
    }
}
