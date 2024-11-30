public struct Lifetime<T> {
  typealias Factory = () -> T
  
  let instance: (Factory) -> T
  
  init(instance: @escaping (Factory) -> T) {
    self.instance = instance
  }
}

extension Lifetime {
  public static var singleton: Lifetime<T> {
    let value = Atomic<T?>(nil)
    return Lifetime { factory -> T in
      value.withLock { value in
        let returnedValue = value ?? factory()
        value = returnedValue
        return returnedValue
      }
    }
  }
  
  public static var unique: Lifetime<T> {
    Lifetime { factory -> T in factory() }
  }
}
