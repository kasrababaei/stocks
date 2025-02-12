import SwiftUI

extension UIHostingController {
    @discardableResult
    func forceRender() -> (
        Task<Void, Never>,
        continuation: (() -> Void)
    ) {
        _render(seconds: 0)
        let (stream, continuation) = AsyncStream<Void>.makeStream()
        let task = Task {
            for await _ in stream {}
            try? Task.checkCancellation()
        }

        return (task, continuation.finish)
    }
}
