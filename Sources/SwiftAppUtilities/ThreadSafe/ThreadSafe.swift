private import Foundation

/// A property wrapper used to make a property Thread Safe.
/// 
/// The `ThreadSafe` object will wrap `get` and `set` calls using a `pthread_rwlock_t` so to optimize the read write performances.
///
/// - Note: An object using multiple `@ThreadSafe` objects in its implementation details is technically `Sendable` but you can still experience out of order
/// sequence if you modify multiple `@ThreadSafe` properties within your methods in a concurrent execution.
/// To avoid such issues you should consider using a critical section so to protect your multiple `@ThreadSafe` properties being un-deterministically modified
/// concurrently in a mixed order.
@propertyWrapper
public final class ThreadSafe<T>: @unchecked Sendable {

  private var lock = pthread_rwlock_t()
  private var value: T
  
  /// The value wrapped.
  public var wrappedValue: T {
    get {
      pthread_rwlock_rdlock(&lock); defer { pthread_rwlock_unlock(&lock) }
      return self.value
    }
    set {
      pthread_rwlock_wrlock(&lock); defer { pthread_rwlock_unlock(&lock) }
      self.value = newValue
    }
  }
  
  /// Designated Initializer
  ///
  /// - Parameter wrappedValue: The initial value of the property wrapper.
  public init(wrappedValue: T) {
    pthread_rwlock_init(&lock, nil)
    self.value = wrappedValue
  }

  deinit {
    pthread_rwlock_destroy(&lock)
  }
}

public extension ThreadSafe {
  
  /// A convenience initializer. It behaves exactly like ``init(wrappedValue:)``
  /// - Parameter wrappedValue: The initial value of the property wrapper.
  convenience init(_ wrappedValue: T) {
    self.init(wrappedValue: wrappedValue)
  }
}

extension ThreadSafe: Equatable where T: Equatable {

  public static func ==(lhs: ThreadSafe, rhs: ThreadSafe) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension ThreadSafe: Identifiable where T: Identifiable {
  public var id: T.ID { self.wrappedValue.id }
}

extension ThreadSafe: Hashable where T: Hashable {

  public var hashValue: Int {
    self.wrappedValue.hashValue
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.wrappedValue.hashValue)
  }
}
