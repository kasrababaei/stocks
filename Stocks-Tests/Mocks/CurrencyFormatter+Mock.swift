@testable import Stocks
@testable import StocksCore

final class MockCurrencyFormatter: CurrencyFormatter {
  var numberCallCount: Int { numberParametersList.count }
  var numberParametersList: [String] = []
  var numberReturnValue: Int? = nil
  func number(from string: String) -> Int? {
    numberParametersList.append(string)
    return numberReturnValue
  }
}
