import Foundation
import StocksCore

final class MockExecutionContext: ExecutionContext {
  var sleepCount: Int { sleepParameterList.count }
  var sleepParameterList: [TimeInterval] = []
  var sleepReturnCall: (() async throws -> Void)!
  func sleep(for seconds: TimeInterval) async throws {
    sleepParameterList.append(seconds)
    return try await sleepReturnCall()
  }
  
  var executeCount: Int { executeParameterList.count }
  var executeParameterList: [(() async -> Void)] = []
  var executeOperation: (() async -> Void)? { executeParameterList.last }
  var executeReturnValue: Task<Void, Never>!
  func execute(_ operation: sending @escaping @isolated(any) () async -> Void) -> Task<Void, Never> {
    executeParameterList.append(operation)
    return executeReturnValue
  }
    
    var _executeCount: Int { _executeParameterList.count }
  var _executeParameterList: [(() -> Void)] = []
  var _executeOperation: (() -> Void)? { _executeParameterList.last }
    func dispatchQueueExecute(closure: @escaping () -> Void) {
        
    _executeParameterList.append(closure)
  }
    
    
}
