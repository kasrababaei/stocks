import OSLog

public enum ConsoleLogger {
  @_transparent
  public static func log(
    fileID: String = #fileID,
    function: String = #function,
    line: Int = #line,
    level: Level = .debug,
    _ message: Any?...
  ) {
    let relativePathComponents = fileID.split(separator: "/")
    
    let logger = Logger(
      subsystem: "\(relativePathComponents.first ?? "")",
      category: "\(relativePathComponents.last ?? "")"
    )
    let joinedMessage = message.map { value in
      switch value {
      case let .some(message): String(describing: message)
      case .none: "nil"
      }
    }.joined(separator: " ")
    
    var _level: OSLogType {
      return switch level {
      case .debug: .debug
      case .info: .info
      case .error: .error
      case .fault: .fault
      }
    }
    
    logger.log(level: _level, "\(function):\(line) -> \(joinedMessage)")
  }
}

public extension ConsoleLogger {
  @frozen enum Level: String {
    case debug
    case info
    case error
    case fault
  }
}
