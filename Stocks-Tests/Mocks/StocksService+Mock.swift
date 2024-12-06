@testable import Stocks
@testable import StocksCore

final class MockStocksService: StocksService, @unchecked Sendable {
  var stocksCallCount = 0
  var stockReturnCall: (() async throws -> [Stock])!
  func stocks() async throws -> [Stock] {
    stocksCallCount += 1
    return try await stockReturnCall()
  }
}
