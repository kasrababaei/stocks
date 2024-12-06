import SwiftUI
import StocksCore

struct ToastModifier: ViewModifier {
  @Binding var toast: ToastDetail?
  @State private var task: Task<(), Never>?
  
  func body(content: Content) -> some View {
    content
      .overlay {
        toastBody(toast)
          .offset(y: 32)
      }
      .animation(.spring(), value: toast)
      .onChange(of: toast) { _ in scheduleDismissal() }
  }
  
  @ViewBuilder func toastBody(_ toast: ToastDetail?) -> some View {
    VStack {
      if let toast = toast {
        ToastView(toast: toast)
      }
      Spacer()
    }
  }
  
  private func scheduleDismissal() {
    if task != nil {
      dismissToast()
    }
    
    task = Task {
      try? await Task.sleep(for: .seconds(3))
      dismissToast()
    }
  }
  
  private func dismissToast() {
    withAnimation {
      toast = nil
      task = nil
    }
  }
}

extension View {
  func present(toast: Binding<ToastDetail?>) -> some View {
    self.modifier(ToastModifier(toast: toast))
  }
}
