import Foundation

public struct ToastDetail: Identifiable, Equatable, Sendable {
  public let id: UUID
  public let title: String
  public let message: String?
  
  public init(title: String, message: String? = nil) {
    self.id = UUID()
    self.title = title
    self.message = message
  }
  
  public init(error: Error) {
    self.id = UUID()
    self.title = "Something went wrong"
    self.message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
  }
}
