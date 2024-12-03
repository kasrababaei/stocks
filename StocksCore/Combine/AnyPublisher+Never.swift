import Combine

public extension AnyPublisher {
  static func never() -> AnyPublisher<Output, Failure> {
    Empty(completeImmediately: false).eraseToAnyPublisher()
  }
}
