import Foundation
import Testing
@testable import Stocks
@testable import StocksCore
@testable import StocksLogger

@MainActor
final class StocksListViewModelTests {
  let mockService: MockStocksService
  let mockCurrencyFormatter: MockCurrencyFormatter
  let mockExecutionContext: MockExecutionContext
  
  init() {
    Instantiator.mocking.withLock { $0 = .enabled(required: true) }
    ConsoleLogger.isTesting = true
    
    let mockService = MockStocksService()
    self.mockService = mockService
    mock(StocksService.self) { mockService }
    
    let mockCurrencyFormatter = MockCurrencyFormatter()
    self.mockCurrencyFormatter = mockCurrencyFormatter
    mock(CurrencyFormatter.self) { mockCurrencyFormatter }
    
    let mockExecutionContext = MockExecutionContext()
    mockExecutionContext.sleepReturnCall = {}
    mockExecutionContext.executeReturnValue = Task {}
    self.mockExecutionContext = mockExecutionContext
    mock(ExecutionContext.self) { mockExecutionContext }
  }
  
  @Test("Should call stocks on the service")
  func loadData() async {
    mockService.stockReturnCall = { [] }
    
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    #expect(mockService.stocksCallCount == 1)
  }
  
  @Test("When service fails, should assign the toast")
  func loadDataFailed() async {
    let error: Error = MockError()
    mockService.stockReturnCall = { throw error }
    
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    
    let expectedToast = StocksCore.ToastDetail(error: error)
    #expect(viewModel.toast?.message == expectedToast.message)
  }
  
  @Test("When service returns, contentUnavailable should be true when items is empty")
  func contentUnavailableBecomesTrue() async {
    mockService.stockReturnCall = { [] }
    
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    
    #expect(viewModel.contentUnavailable)
  }
  
  @Test("When service returns, should load first page")
  func loadFirstPage() async {
    let stocks = Stock.mockData()
    
    mockService.stockReturnCall = { stocks }
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    #expect(viewModel.items.count == StocksListViewModel.pageSize)
    #expect(!viewModel.contentUnavailable)
    #expect(viewModel.toast == nil)
  }
  
  @Test("When when requested next page, should append a new page")
  func loadNextPage() async {
    let stocks = Stock.mockData()
    
    mockService.stockReturnCall = { stocks }
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    viewModel.loadNext()
    #expect(viewModel.items.count == StocksListViewModel.pageSize * 2)
  }
  
  @Test("When searched a valid term, should populate it")
  func searchTricker() async throws {
    let stocks = [
      Stock(name: "AAA", ticker: "[Apple]", currentPrice: 101),
      Stock(name: "BBB", ticker: "[Amazon]", currentPrice: 286),
      Stock(name: "CCC", ticker: "[Google]", currentPrice: 999)
    ]
    
    mockService.stockReturnCall = { stocks }
    let viewModel = StocksListViewModel()
    await viewModel.loadData()
    
    viewModel.searchText = stocks[0].ticker
    await mockExecutionContext.executeOperation?()
    #expect(viewModel.items.contains(where: { $0.stock.ticker == stocks[0].ticker }))
    
    viewModel.searchText = stocks[1].name
    await mockExecutionContext.executeOperation?()
    #expect(viewModel.items.contains(where: { $0.stock.ticker == stocks[1].ticker }))
    
    viewModel.searchText = "\(stocks[2].currentPrice.amount)"
    await mockExecutionContext.executeOperation?()
    #expect(viewModel.items.contains(where: { $0.stock.ticker == stocks[2].ticker }))
  }
}

private struct MockError: Error {
  let id: UUID
  var localizedDescription: String {
    id.uuidString
  }
  
  init() {
    self.id = UUID()
  }
}
