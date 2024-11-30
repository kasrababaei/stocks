import Combine

/// A cancellable object that is safe to be passed across concurrency domains.
///
/// An `AtomicCancellable` instance automatically calls `cancel()` when deinitialized.
/// Calling `store(cancellable:)` more than once in any order causes a crash.
/// Calling `cancel` before `store` would cause the following call to `store` to immediately invoke
/// the cancel closure.
public final class AtomicCancellable: Sendable, Cancellable {
  typealias CancelationHandler = (() -> Void)?
  
  private let state: Atomic<State> = .init(.initialized)
  
  public init() {}
  deinit { cancel() }
  
  public func store(onCancel cancel: @escaping () -> Void) {
    state.withLock { state in
      switch state {
      case .initialized:
        state = .stored(cancel)
      case .cancelledBeforeStoring:
        cancel()
        state = .cancelledAfterStoring
      case .stored, .cancelledAfterStoring:
        fatalError("Store can only be called once.")
      }
    }
  }
  
  public func cancel() {
    state.withLock { state in
      switch state {
      case .initialized:
        state = .cancelledBeforeStoring
      case let .stored(handler):
        handler()
        state = .cancelledAfterStoring
      case .cancelledBeforeStoring, .cancelledAfterStoring:
        break
      }
    }
  }
}

private extension AtomicCancellable {
  enum State {
    case initialized
    case stored(() -> Void)
    case cancelledBeforeStoring
    case cancelledAfterStoring
  }
}

public extension AtomicCancellable {
  func store(cancellable: any Cancellable) {
    store(onCancel: cancellable.cancel)
  }
}
