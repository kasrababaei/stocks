import Foundation
import StocksCore
import StocksLogger
import SwiftUI

@MainActor
protocol StocksListViewViewModel: ObservableObject {
  associatedtype Item: StockRowViewModel & Identifiable
  
  var items: [Item] { get }
  var searchText: String { get set }
  var toast: ToastDetail? { get set }
  var contentUnavailable: Bool { get }
  
  func loadData() async
  func loadNext()
}

struct StocksListView<ViewModel: StocksListViewViewModel>: View {
  @ObservedObject private var viewModel: ViewModel
  @Environment(\.isSearching) private var isSearching
  @State private var isLoading = false
  @State private var searchText = ""
  @State private var taskId = UUID()
  @State private var isShowingToast = false
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack {
          ForEach(viewModel.items) { StockRow(viewModel: $0) }
          
          if isLoading {
            ProgressView()
          }
          
          Color.clear
            .onAppear { loadNext() }
            .id(viewModel.items.last?.id)
        }
      }
      .refreshable {
        guard !isLoading else { return }
        taskId = UUID()
      }
      .task(id: taskId) { await loadData() }
      .searchable(text: $viewModel.searchText, prompt: Text("Search by name or ticker"))
      .navigationTitle("Stocks List")
    }
    .overlay {
      if viewModel.contentUnavailable {
        Button("Retry") {
          Task { await loadData() }
        }
      }
    }
    .present(toast: $viewModel.toast)
  }
  
  private func loadData() async {
    ConsoleLogger.log()
    
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }
    await viewModel.loadData()
  }
  
  private func loadNext() {
    ConsoleLogger.log()
    
    guard !isLoading else { return }
    isLoading = true
    defer { isLoading = false }
    viewModel.loadNext()
  }
}

#if DEBUG && targetEnvironment(simulator)
#Preview("Loaded") {
  NavigationStack { StocksListView(viewModel: StocksListViewViewModel.Mock.loaded()) }
}

#Preview("Loading") {
  NavigationStack { StocksListView(viewModel: StocksListViewViewModel.Mock.loading()) }
}

#Preview("Content Unavailable") {
  NavigationStack { StocksListView(viewModel: StocksListViewViewModel.Mock.contentUnavailable()) }
}
#endif
