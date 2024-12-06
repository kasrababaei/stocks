import Foundation

public struct Currency: Sendable, Hashable {
  /// The amount in the currency's smallest unit
  /// eg. Cents in CAD
  public let amount: Int
  
  /// A three character ISO 4217 currency code
  public let currencyCode: String
  
  public init(amount: Double, currencyCode: String = "CAD") {
    self.amount = Int((amount * 100) / 100)
    self.currencyCode = currencyCode
  }
  
  public init(amount: Int, currencyCode: String = "CAD") {
    self.amount = amount
    self.currencyCode = currencyCode
  }
}

extension Currency: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    
    do {
      let amount = try container.decode(Double.self)
      
      self.init(amount: amount)
    } catch {
      let amount = try container.decode(Int.self)
      
      self.init(amount: amount)
    }
  }
}

extension Currency: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self.init(amount: value)
  }
}
