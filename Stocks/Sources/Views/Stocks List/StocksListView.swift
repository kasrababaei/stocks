import Combine
import Foundation
import StocksCore
import StocksLogger
import SwiftUI

@MainActor
protocol StocksListViewViewModel: ObservableObject {
  associatedtype Item: StockRowViewModel & Identifiable
  
  var items: [Item] { get set }
  var error: AnyPublisher<Error, Never> { get }
  
  func loadData() async
  func loadNext()
  func searchBarTextDidChange(_ searchText: String)
}

struct StocksListView<ViewModel: StocksListViewViewModel>: View {
  @ObservedObject private var viewModel: ViewModel
  
  @State private var isLoading = false
  @State private var searchText = ""
  @Environment(\.isSearching) private var isSearching
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(viewModel.items) { StockRow(viewModel: $0) }
        
        if isLoading {
          ProgressView()
        }
        
        Color.clear
          .onAppear { [viewModel] in viewModel.loadNext() }
          .id(viewModel.items.last?.id)
      }
    }
    .refreshable { await refresh() }
    .task { await loadData() }
    .searchable(text: $searchText, prompt: Text("Search by name or ticker"))
    .onChange(of: searchText) { [viewModel] searchText in
      viewModel.searchBarTextDidChange(searchText)
    }
    .navigationTitle("Stocks List")
  }
  
  private func refresh() async {
    ConsoleLogger.log()
    
    guard !isLoading else { return }
    viewModel.items = []
    isLoading = true
    defer { isLoading = false }
    await viewModel.loadData()
  }
  
  private func loadData() async {
    ConsoleLogger.log()
    
    isLoading = true
    defer { isLoading = false }
    await viewModel.loadData()
  }
}

#if DEBUG
private final class MockViewModel: StocksListViewViewModel {
  @Published var items: [Item] = []
  let searchResult: [Item] = []
  var error: AnyPublisher<Error, Never> = .never()
  
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
  
  func searchBarTextDidChange(_ searchText: String) {
    //
  }
}

extension MockViewModel {
  struct Item: StockRowViewModel, Identifiable {
    let id = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: String { "$\(stock.currentPrice)" }
    
    let stock: Stock
  }
}

#Preview {
  NavigationStack { StocksListView(viewModel: MockViewModel()) }
}
#endif
