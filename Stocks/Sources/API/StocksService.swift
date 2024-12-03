import Foundation
import StocksCore

let getStocksService = bind(StocksService.self) {
  StocksAPIService()
}

protocol StocksService: Sendable {
  func stocks() async throws -> [Stock]
}

private struct StocksAPIService: StocksService {
  func stocks() async throws -> [Stock] {
    try await getAPIClient().fetch<[Stock]>(with: Schema.stocks)
  }
}

private enum Schema {
  static var stocks: URL {
    [
      "0e1d4f8d517698cfdced49f5e59567be",
      "raw",
      "9158ad254e92aaffe215e950f4846a23a0680703",
      "mock-stocks.json"
    ].reduce(into: Server.base) { $0.append(path: $1) }
  }
}
