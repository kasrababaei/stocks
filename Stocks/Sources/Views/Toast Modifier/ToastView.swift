import StocksCore
import SwiftUI

struct ToastView: View {
  let toast: Toast
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(toast.title)
        .font(.caption)
        
      if let message = toast.message {
        Text(message)
          .font(.caption2)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(32)
    .background {
      RoundedRectangle(cornerRadius: 6)
        .fill(Color("toast"))
        .blur(radius: 6)
        .padding(6)
    }
  }
}


#if DEBUG
private extension Toast {
  static var mock: Toast {
    Toast(title: "Mock Toast Message")
  }
}

#Preview {
  ToastView(toast: .mock)
}
#endif
