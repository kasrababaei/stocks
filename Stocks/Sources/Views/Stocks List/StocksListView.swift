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

#if DEBUG
private final class MockViewModel: StocksListViewViewModel {
  @Published var items: [Item] = []
  var searchText: String = ""
  var toast: ToastDetail? = nil
  var contentUnavailable: Bool = false
  
  private let mockData: [Stock] = Stock.mockData(count: 50)
  
  func loadData() async {
    items = Array(mockData.prefix(10)).map(Item.init)
  }
  
  func loadNext() {
    let start = items.count
    let end = start + 10
    guard end < mockData.count else { return }
    items.append(contentsOf: mockData[start...end].map(Item.init))
  }
}

extension MockViewModel {
  struct Item: StockRowViewModel, Identifiable {
    let id = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: Currency { stock.currentPrice }
    
    let stock: Stock
  }
}

#Preview {
  NavigationStack { StocksListView(viewModel: MockViewModel()) }
}
#endif
