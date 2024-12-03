import Combine
import Foundation
import StocksCore
import SwiftUI

@MainActor
protocol StocksListViewViewModel: ObservableObject {
  associatedtype Item: StockRowViewModel & Identifiable
  
  var items: [Item] { get set }
  var error: AnyPublisher<Error, Never> { get }
  
  func loadData() async
  func loadNext() async
}

struct StocksListView<ViewModel: StocksListViewViewModel>: View {
  @ObservedObject
  private var viewModel: ViewModel
  
  @State
  private var isLoading = false
  
  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(viewModel.items) { item in
          VStack(spacing: 8) {
            StockRow(viewModel: item)
            Divider()
          }
          .task { [viewModel] in
            guard item.id == viewModel.items.last?.id else {
              return
            }
            
            await viewModel.loadNext()
          }
          .padding(.horizontal)
        }
      }
    }
    .refreshable { [viewModel] in
      ConsoleLogger.log()
      
      guard !isLoading else { return }
      viewModel.items = []
      isLoading = true
      await viewModel.loadData()
      isLoading = false
    }
    .task { [viewModel] in
      ConsoleLogger.log()
      
      
      isLoading = true
      await viewModel.loadData()
      isLoading = false
    }
    .navigationTitle("Stocks List")
  }
}

#if DEBUG
private final class MockViewModel: StocksListViewViewModel {
  struct Item: StockRowViewModel, Identifiable {
    let id = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: String { "$\(stock.currentPrice)" }
    
    let stock: Stock
  }
  
  @Published var items: [Item] = []
  var error: AnyPublisher<Error, Never> = .never()
  
  private let mockData: [Stock] = Stock.mockData(count: 50)
  
  func loadData() async {
    items = Array(mockData.prefix(10)).map(Item.init)
  }
  
  func loadNext() async {
    let start = items.count
    let end = start + 10
    guard end < mockData.count else { return }
    items.append(contentsOf: mockData[start...end].map(Item.init))
  }
}

#Preview {
  NavigationStack { StocksListView(viewModel: MockViewModel()) }
}
#endif
