import Foundation
import StocksCore

extension StocksListViewModel {
  struct Item: StockRowViewModel, Identifiable, Equatable {
    let id: String = UUID().uuidString
    var ticker: String { stock.ticker }
    var name: String { stock.name }
    var currentPrice: Currency { stock.currentPrice }
    
    let stock: Stock
  }
}
