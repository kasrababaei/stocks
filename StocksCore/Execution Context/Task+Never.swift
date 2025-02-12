public extension Task where Success == Never, Failure == Never {
    /// An async function that never returns but throws if the task is cancelled.
    static func sleepForever() async throws {
        for await _ in AsyncStream<Never>.never() {}
        try Task.checkCancellation()
    }
}

public extension AsyncStream {
    /// An `AsyncStream` that never emits and never completes unless cancelled.
    static func never() -> Self {
        Self { _ in }
    }
}
