import Foundation

//let getCurrencyFormatter

protocol CurrencyFormatter {
  func number(from string: String) -> Int?
}

struct AnyCurrencyFormatter: CurrencyFormatter {
  private let formatter: NumberFormatter = .init()
  
  func number(from string: String) -> Int? {
    formatter.numberStyle = .currency
    let number = formatter.number(from: string)
    return number.map { Int(truncating: $0) }
  }
}
