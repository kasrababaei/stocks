import Foundation

public let getExecutionContext = bind(ExecutionContext.self) {
  DefaultExecutionContext()
}

public protocol ExecutionContext {
  func sleep(for seconds: TimeInterval) async throws
  
  @discardableResult
  func execute(_ operation: sending @escaping @isolated(any) () async -> Void) -> Task<Void, Never>
    
    func dispatchQueueExecute(closure: @escaping () -> Void)
}

private struct DefaultExecutionContext: ExecutionContext {
  func sleep(for seconds: Double) async throws {
    try await Task.sleep(for: .seconds(seconds))
  }
  
  @discardableResult
  func execute(_ operation: sending @escaping @isolated(any) () async -> Void) -> Task<Void, Never> {
    Task(operation: operation)
  }
    
    func dispatchQueueExecute(closure: @escaping () -> Void) {
        DispatchQueue.main.async(execute: closure)
    }
}
