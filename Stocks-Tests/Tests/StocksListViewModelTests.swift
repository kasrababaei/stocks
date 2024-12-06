import Foundation
import Testing
@testable import Stocks
@testable import StocksCore
@testable import StocksLogger

@Suite(.serialized)
final class StocksListViewModelTests {
  let mockService: MockStocksService
  
  init() {
    Instantiator.mocking.withLock { $0 = .enabled(required: true) }
    ConsoleLogger.isTesting = true
    
    let mockService = MockStocksService()
    mock(StocksService.self) { mockService }
    
    self.mockService = mockService
  }
  
  @Test("Should call stocks on the service")
  func loadData() async {
    mockService.stockReturnCall = { [] }
    
    let viewModel = await StocksListViewModel()
    await viewModel.loadData()
    #expect(mockService.stocksCallCount == 1)
  }
  
  @Test("When service fails, should not append items")
  func loadDataFailed() async {
    let expectedError = MockError()
    mockService.stockReturnCall = { throw MockError() }
    
    let viewModel = await StocksListViewModel()
    await viewModel.loadData()
    
  }
  
  @Test("When service returns, should load first page")
  func loadFirstPage() async {
    let stocks = Stock.mockData()
    
    mockService.stockReturnCall = { stocks }
    let viewModel = await StocksListViewModel()
    await viewModel.loadData()
    await #expect(viewModel.items.count == StocksListViewModel.pageSize)
  }
  
  @Test("When when requested next page, should append a new page")
  func loadNextPage() async {
    let stocks = Stock.mockData()
    
    mockService.stockReturnCall = { stocks }
    let viewModel = await StocksListViewModel()
    await viewModel.loadData()
    await viewModel.loadNext()
    await #expect(viewModel.items.count == StocksListViewModel.pageSize * 2)
  }
}

private struct MockError: Error {
  let id: UUID
  
  init() {
    self.id = id
  }
}
