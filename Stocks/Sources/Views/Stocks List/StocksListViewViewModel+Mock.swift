import Combine
import Foundation
import StocksCore

#if DEBUG && targetEnvironment(simulator)
extension StocksListViewViewModel {
  typealias Mock = MockStocksListViewViewModel
}

final class MockStocksListViewViewModel: StocksListViewViewModel {
  @Published var items: [Item] = []
  var searchText: String = ""
  var toast: ToastDetail? = nil
  var contentUnavailable: Bool = false
  
  var mockLoadData: (() async -> ())? = nil
  func loadData() async {
    await mockLoadData?()
  }
  
  var mockLoadNext: (() -> ())? = nil
  func loadNext() {
    mockLoadNext?()
  }
}

extension MockStocksListViewViewModel {
  struct Item: StockRowViewModel, Identifiable {
    let id = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: Currency { stock.currentPrice }
    
    let stock: Stock
  }
}

// MARK: - StocksListViewViewModel.Mock + Test States
extension StocksListViewViewModel.Mock {
  static func loading() -> StocksListViewViewModel.Mock {
    let viewModel = StocksListViewViewModel.Mock()
    
    viewModel.mockLoadData = { try? await Task.sleepForever() }
    
    return viewModel
  }
  
  static func loaded() -> StocksListViewViewModel.Mock {
    let mockData: [Stock] = Stock.mockStocks(count: 50)
    
    let viewModel = StocksListViewViewModel.Mock()
    viewModel.mockLoadData = { viewModel.items = Array(mockData.prefix(10)).map(Item.init) }
    viewModel.mockLoadNext = {
      let start = viewModel.items.count
      let end = start + 10
      guard end < mockData.count else { return }
      viewModel.items.append(contentsOf: mockData[start...end].map(Item.init))
    }
    
    return viewModel
  }
  
  static func loadNext() -> StocksListViewViewModel.Mock {
    let viewModel = StocksListViewViewModel.Mock()
    viewModel.items = Stock.mockStocks(count: 5).map { StocksListViewViewModel.Mock.Item(stock: $0) }
    viewModel.mockLoadData = { try? await Task.sleepForever() }
    
    return viewModel
  }
  
  static func contentUnavailable() -> StocksListViewViewModel.Mock {
    let viewModel = StocksListViewViewModel.Mock()
    viewModel.contentUnavailable = true
    return viewModel
  }
}
#endif
