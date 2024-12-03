import Combine
import Foundation

public let getAPIClient = bind(AnyAPIClient.self, lifetime: .singleton) {
  APIClient()
}

public protocol AnyAPIClient: Sendable {
  func fetch<T: Decodable>(with url: URL) async throws -> T
  
  func fetch(with url: URL) async throws -> Data
  
  func fetch(
    with url: URL,
    completionHandler: @escaping @Sendable (Result<Data, any Error>) -> Void
  ) -> any Cancellable
}

private final class APIClient: AnyAPIClient {
  func fetch<T>(with url: URL) async throws -> T where T : Decodable {
    let data = try await fetch(with: url)
    return try JSONDecoder().decode(T.self, from: data)
  }
  
  func fetch(
    with url: URL
  ) async throws -> Data {
    ConsoleLogger.log(level: .info, url.debugDescription)
    
    let atomicCancellable = AtomicCancellable()
    let failure = Result<Data, any Error>.failure(CancellationError())
    
    return try await withTaskCancellationHandler {
      try Task.checkCancellation()
      
      return try await withCheckedThrowingContinuation { continuation in
        let hasContinued = Atomic(false)
        let resumeWith: @Sendable (Result<Data, any Error>) -> Void = { result in
          hasContinued.withLock { hasContinued in
            guard !hasContinued else { return }
            do {
              try continuation.resume(returning: result.get())
            } catch {
              continuation.resume(throwing: error)
            }
            hasContinued = true
          }
        }
        
        guard !Task.isCancelled else {
          resumeWith(failure)
          return
        }
        
        let cancellable = fetch(with: url) { result in
          let mappedResult = Task.isCancelled ? failure : result
          resumeWith(mappedResult)
        }
        
        atomicCancellable.store {
          cancellable.cancel()
          
          guard !hasContinued.value else { return }
          // In case the cancellation handler gets invoked before the operation is called,
          // we should call resume on the continuation; otherwise, the continuation gets
          // leaked and the task stays hanging indefinitely.
          resumeWith(failure)
        }
      }
    } onCancel: {
      atomicCancellable.cancel()
    }
  }
  
  func fetch(
    with url: URL,
    completionHandler: @escaping @Sendable (Result<Data, any Error>) -> Void
  ) -> any Cancellable {
    ConsoleLogger.log(level: .info, url.debugDescription)
    
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    
    let task = getURLSession().dataTask(
      with: request,
      name: request.debugDescription,
      completionHandler: mapURLSessionResult(to: completionHandler)
    )
    
    task.resume()
    
    return task
  }
  
  private func mapURLSessionResult(
    to completion: @escaping @Sendable (Result<Data, any Error>) -> Void
  ) -> @Sendable (Result<(data: Data?, response: HTTPURLResponse), any Error>) -> Void {
    { result in
      do {
        let response = try result.get()
        guard let data = response.data else {
          throw APIClientError.unknown
        }
        
        completion(.success(data))
      } catch {
        completion(.failure(error))
      }
    }
  }
}
