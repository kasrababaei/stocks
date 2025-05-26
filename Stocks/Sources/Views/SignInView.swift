import SwiftUI

@MainActor
protocol SignInViewViewModel: ObservableObject {
  var username: String { get set }
  var password: String { get set }
  var isLoading: Bool { get }
  var error: String { get set }

  func loadData() async
  func loginTapped() async
  func forgotPasswordTapped()
}

struct SignInView<VM: SignInViewViewModel>: View {
  @ObservedObject
  private(set) var viewModel: VM

  private var canLogIn: Bool {
    !viewModel.isLoading
    && !viewModel.username.isEmpty
    && !viewModel.password.isEmpty
  }

  var body: some View {
    VStack {
      TextField(text: $viewModel.username) { Text("Username") }
      TextField(text: $viewModel.password) { Text("Password") }

      ProgressView().opacity(viewModel.isLoading ? 1 : 0)

      Button(
        action: {
          Task {
            viewModel.error = ""
            await viewModel.loginTapped()
          }
        },
        label: { Text("Sign In") }
      )
      .disabled(!canLogIn)

      Button(
        action: viewModel.forgotPasswordTapped,
        label: { Text("Forgot Password?") }
      )
      .disabled(viewModel.isLoading)

      Text(viewModel.error)
    }
    .task { await viewModel.loadData() }
  }
}

#Preview("Loading") {
  SignInView(viewModel: SignInViewViewModel.Mock.loading)
}

#Preview("Loaded") {
  SignInView(viewModel: SignInViewViewModel.Mock.loaded)
}

#Preview("Finished with Error") {
  SignInView(viewModel: SignInViewViewModel.Mock.finishedWithError)
}

#Preview("Logging In") {
  SignInView(viewModel: SignInViewViewModel.Mock.loggingIn)
}

// MARK: - SignInViewModel
final class SignInViewModel: SignInViewViewModel {
  @Published var username: String = ""
  @Published var password: String = ""
  var isLoading: Bool = false
  var error: String = ""

  func loginTapped() async { /* Real implementation */ }
  func forgotPasswordTapped() { /* Real implementation */ }
  func loadData() async { /* Real implementation */ }
}

// MARK: - SignInViewViewModel + Mock & States
extension SignInViewViewModel {
  typealias Mock = MockSignInViewModel

  static var loading: Mock { Mock(isLoading: true) }
  static var loaded: Mock { Mock() }
  static var finishedWithError: Mock { Mock(error: "Error Message") }
  static var loggingIn: Mock { Mock(username: "name@email.com", password: "1234", isLoading: true) }
}

final class MockSignInViewModel: SignInViewViewModel {
  @Published var username: String
  @Published var password: String
  @Published var isLoading: Bool
  @Published var error: String

  init(username: String = "", password: String = "", isLoading: Bool = false, error: String = "") {
    self.username = username
    self.password = password
    self.isLoading = isLoading
    self.error = error
  }

  func loginTapped() async {}
  func forgotPasswordTapped() {}

  var loadDataCallCount = 0
  var wasLoadDataCalled: Bool { loadDataCallCount > 0 }
  func loadData() async {
    loadDataCallCount += 1
  }
}
