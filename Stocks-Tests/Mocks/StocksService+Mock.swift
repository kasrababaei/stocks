@testable import Stocks
@testable import StocksCore

@MainActor
final class MockStocksService: StocksService {
  var stocksCallCount = 0
  var stockReturnCall: (() async throws -> [Stock])!
  func stocks() async throws -> [Stock] {
    stocksCallCount += 1
    return try await stockReturnCall()
  }
}
