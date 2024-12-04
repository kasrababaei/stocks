import Foundation
import Combine
import StocksCore

final class StocksListViewModel: StocksListViewViewModel {
  private static let pageSize = 10
  
  @Published var items: [Item] = []
  var error: AnyPublisher<Error, Never> = .never()
  
  private var stocks: [Stock] = []
  
  private var isLoading = false
  
  func loadData() async {
    ConsoleLogger.log()
    
    guard !isLoading else { return }
    isLoading = true
    
    do {
      stocks = try await getStocksService().stocks()
      isLoading = false
    } catch {
      ConsoleLogger.log(level: .error, error)
      isLoading = false
    }
    
    await loadNext()
  }
  
  func loadNext() async {
    ConsoleLogger.log()
    
    guard !isLoading else { return }
    
    let start = items.count
    let end = start + Self.pageSize
    
    guard [start, end].allSatisfy({ $0 < stocks.count }) else {
      ConsoleLogger.log("No more next page.")
      return
    }
    
    items.append(contentsOf: stocks[start...end].map { Item(stock: $0) })
  }
  
  private var searchTask: Task<Void, Never>?
  
  func searchBarTextDidChange(_ searchText: String) {
    searchTask?.cancel()
    searchTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(0.5))
      guard !Task.isCancelled else { return }
      self?.filterStocks(searchText)
    }
  }
  
  private func filterStocks(_ searchText: String) {
    ConsoleLogger.log(searchText)
  }
}
