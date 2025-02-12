public struct Stock: Decodable, Equatable, Sendable {
  public let name: String
  public let ticker: String
  public let currentPrice: Currency
}

#if DEBUG && targetEnvironment(simulator)
extension Stock {
  public static func mockStocks(count: Int = 1) -> [Stock] {
    (0..<count).map { index in
      Stock(
        name: "Stock Number [\(index)]",
        ticker: "AAA",
        currentPrice: Currency(amount: index)
      )
    }
  }
}
#endif
