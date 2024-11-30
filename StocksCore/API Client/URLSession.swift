import Combine
import Foundation
import os.log

let getURLSession = bind(AnyURLSession.self) {
  URLSession()
}

protocol AnyURLSession: Sendable {
  func dataTask(
    with request: URLRequest,
    name: String?,
    completionHandler: @escaping @Sendable (Result<(data: Data?, response: HTTPURLResponse), any Error>) -> Void
  ) -> URLSessionTask
}

protocol URLSessionTask: Cancellable {
  func resume()
}

extension URLSessionDataTask: @retroactive Cancellable {}
extension URLSessionDataTask: URLSessionTask {}

private final class URLSession: AnyURLSession {
  private let urlSession: Foundation.URLSession
  
  init() {
    let configuration = URLSessionConfiguration.default
    configuration.httpCookieAcceptPolicy = .never
    configuration.httpShouldSetCookies = false
    configuration.httpAdditionalHeaders = [
      "content-type": "application/json"
    ]
    
    self.urlSession = .init(configuration: configuration)
  }
  
  func dataTask(
    with request: URLRequest,
    name: String?,
    completionHandler: @escaping @Sendable (Result<(data: Data?, response: HTTPURLResponse), any Error>) -> Void
  ) -> URLSessionTask {
    let completion = handleResponse(name: name, completion: completionHandler)
    return urlSession.dataTask(with: request, completionHandler: completion)
  }
  
  private func handleResponse(
    name: String?,
    completion: @escaping @Sendable (Result<(data: Data?, response: HTTPURLResponse), any Error>) -> Void
  ) -> @Sendable (Data?, URLResponse?, Error?) -> Void {
    { data, response, error in
      do {
        guard error == nil else {
          try error.map { throw APIClientError.urlErrorDomain($0) }
          return
        }
        
        let httpResponse = try self.httpURLResponse(name: name, response: response)
        
        try self.verifyStatusCode(for: httpResponse)
        completion(.success((data, httpResponse)))
      } catch {
        completion(.failure(error))
      }
    }
  }
  
  private func httpURLResponse(
    name: String?,
    response: URLResponse?
  ) throws -> HTTPURLResponse {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw APIClientError.httpError
    }
    
    if let name {
      ConsoleLogger.log(name, "httpResponse.statusCode is", httpResponse.statusCode)
    } else {
      ConsoleLogger.log("httpResponse.statusCode is", httpResponse.statusCode)
    }
    
    return httpResponse
  }
  
  private func verifyStatusCode(for response: HTTPURLResponse) throws {
    guard 200..<300 ~= response.statusCode else {
      throw APIClientError.httpError
    }
  }
}
