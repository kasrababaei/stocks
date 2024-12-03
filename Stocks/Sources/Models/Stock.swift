struct Stock: Decodable, Identifiable, Equatable {
  var id: String { name + ticker }
  let name: String
  let ticker: String
  let currentPrice: Double
}

#if DEBUG
extension Stock {
  static func mockData(count: Int = 300) -> [Stock] {
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
