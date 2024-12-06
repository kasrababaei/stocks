import Foundation
import StocksCore
import StocksLogger

final class StocksListViewModel: StocksListViewViewModel {
  static let pageSize = 20
  
  @Published var items: [Item] = []
  var searchText: String = "" { didSet { searchBarTextDidChange() } }
  @Published var toast: Toast? = nil
  @Published var contentUnavailable: Bool = false
  
  private let trickerTrie = Trie<Int>()
  private let nameTrie = Trie<Int>()
  private let currentPriceTrie = Trie<Int>()
  
  private var isSearching = false
  private var isLoading = false
  private var stocks: [Stock] = [] {
    didSet { updateTries() }
  }
  private var allItems: [Item] = []
  var searchTask: Task<Void, Never>?
  
  func loadData() async {
    ConsoleLogger.log()
    contentUnavailable = false
    
    guard !isLoading else { return }
    isLoading = true
    
    do {
      stocks = try await getStocksService().stocks()
      items.removeAll()
    } catch {
      ConsoleLogger.log(level: .error, error)
      toast = Toast(title: "Something went wrong.")
    }
    
    contentUnavailable = stocks.isEmpty
    isLoading = false
    loadNext()
  }
  
  func loadNext() {
    ConsoleLogger.log()
    
    guard !isLoading, !isSearching else { return }
    
    let start = items.count
    let end = start + Self.pageSize
    
    guard [start, end].allSatisfy({ $0 < stocks.count }) else {
      ConsoleLogger.log("No more next page.")
      return
    }
    
    items.append(contentsOf: stocks[start..<end].map { Item(stock: $0) })
    allItems = items
  }
  
  func searchBarTextDidChange() {
    searchTask?.cancel()
    searchTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(0.5))
      guard !Task.isCancelled else { return }
      self?.filterStocks()
    }
  }
  
  private func filterStocks() {
    ConsoleLogger.log(searchText)
    
    let trickers = Set(trickerTrie.values(for: searchText))
    let names = Set(nameTrie.values(for: searchText))
    let currentPrices = Set(currentPriceTrie.values(for: searchText))
    
    let indices = trickers
      .union(names)
      .union(currentPrices)
    
    let searchResult: [Item] = indices.compactMap { index in
      guard stocks.indices.contains(index) else { return nil }
      return Item(stock: stocks[index])
    }
    
    isSearching = !searchText.isEmpty
    items = isSearching ? searchResult : allItems
  }
  
  private func updateTries() {
    [trickerTrie, nameTrie, currentPriceTrie].forEach { $0.removeAll() }
    
    for (index, stock) in stocks.enumerated() {
      trickerTrie.insert(stock.ticker, value: index)
      nameTrie.insert(stock.name, value: index)
      currentPriceTrie.insert("\(stock.currentPrice)", value: index)
    }
  }
}
