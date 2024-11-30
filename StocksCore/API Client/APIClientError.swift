import Foundation

public enum APIClientError: LocalizedError {
  case httpError
  case urlErrorDomain(Error)
  case unknown
}
