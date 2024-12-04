import Foundation

extension StocksListViewModel {
  struct Item: StockRowViewModel, Identifiable {
    let id: String = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: String { "$\(stock.currentPrice)" }
    
    let stock: Stock
  }
}
