import SwiftUI
import StocksCore

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
    .onAppear {
      ConsoleLogger.log("Appeared.")
    }
  }
}

#Preview {
  ContentView()
}
