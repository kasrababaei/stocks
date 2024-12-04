public struct Stock: Decodable, Equatable, Sendable {
  public let name: String
  public let ticker: String
  public let currentPrice: Double
}

#if DEBUG
extension Stock {
  public static func mockData(count: Int = 300) -> [Stock] {
    (0..<count).map {
      Stock(
        name: "Stock Name [\($0)]",
        ticker: String("ABCDEFGH".shuffled()),
        currentPrice: (100...200).randomElement().map(Double.init) ?? 0
      )
    }
  }
}
#endif
