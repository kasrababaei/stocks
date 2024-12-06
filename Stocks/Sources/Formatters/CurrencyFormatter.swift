import Foundation
import StocksCore

let getCurrencyFormatter = bind(CurrencyFormatter.self, lifetime: .singleton) {
  AnyCurrencyFormatter()
}

protocol CurrencyFormatter {
  func number(from string: String) -> Int?
}

private struct AnyCurrencyFormatter: CurrencyFormatter {
  private let formatter: NumberFormatter = .init()
  
  func number(from string: String) -> Int? {
    formatter.numberStyle = .currency
    let number = formatter.number(from: string)
    return number.map { Int(truncating: $0) }
  }
}
