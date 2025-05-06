private import Foundation

/// A property wrapper used to make a property Thread Safe.
/// 
/// The `ThreadSafe` object will wrap `get` and `set` calls using a `pthread_rwlock_t` so to optimize the read write performances.
///
/// If you require both read and write to modify your object you must use the `projectedValue` (`$object.perform { ... }`) so to wrap both read and write into a single lock.
///
/// - Note: An object using multiple `@ThreadSafe` objects in its implementation details is technically `Sendable` but you can still experience out of order
/// sequence if you modify multiple `@ThreadSafe` properties within your methods in a concurrent execution.
/// To avoid such issues you should consider using your own a critical section so to protect your multiple `@ThreadSafe` properties being
/// un-deterministically modified concurrently in a mixed order.
@propertyWrapper
public final class ThreadSafe<T>: @unchecked Sendable {

  private var lock = pthread_rwlock_t()
  private var value: T
  
  /// The value wrapped.
  ///
  /// You should use the `get` and `set` for atomic operation only. Don't use them to read and then write the value since it's likely you will end up
  /// in out of sequence and inconsistent results.
  ///
  /// This will likely end up in out of sequence ❌
  /// ```swift
  /// let value = ThreadSafe(0)
  ///
  /// Task { value.wrappedValue += 1 }
  /// Task { value.wrappedValue += 1 }
  /// Task { value.wrappedValue += 1 }
  /// Task { value.wrappedValue += 1 }
  /// Task { value.wrappedValue += 1 }
  ///
  /// #expect(await waiting(value.wrappedValue == 5))
  /// ```
  /// This instead will behave correctly ✅
  /// ```swift
  /// @ThreadSafe
  /// var value = 0
  /// let criticalSection = $value
  ///
  /// Task.detached { criticalSection.perform { $0 += 1 } }
  /// Task.detached { criticalSection.perform { $0 += 1 } }
  /// Task.detached { criticalSection.perform { $0 += 1 } }
  /// Task.detached { criticalSection.perform { $0 += 1 } }
  /// Task.detached { criticalSection.perform { $0 += 1 } }
  ///
  /// #expect(await waiting(value == 5))
  /// ```
  ///
  /// - Warning: If you need to read write operations to be performed in an atomic manner you must use the
  /// ``projectedValue`` ``CriticalSection`` instead
  public var wrappedValue: T {
    pthread_rwlock_rdlock(&lock); defer { pthread_rwlock_unlock(&lock) }
    return self.value
  }
  
  /// A ``CriticalSection`` object to perform atomic modifications.
  public var projectedValue: CriticalSection {
    CriticalSection(safe: self)
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
  
  /// An Helper object to enable atomic modification of the wrapped object.
  ///
  /// You use this object to perform modifications to the wrapped object in a thread safe manner.
  struct CriticalSection: Sendable {
    
    private let safe: ThreadSafe

    fileprivate init(safe: ThreadSafe) {
      self.safe = safe
    }
    
    /// Perform a modification to the wrapped object in thread safe manner.
    ///
    /// - Parameter execute: The modification closure
    @discardableResult
    public func perform<Output>(_ execute: (inout T) -> Output) -> Output {
      pthread_rwlock_wrlock(&self.safe.lock);
      var object = self.safe.value
      let result = execute(&object)
      self.safe.value = object
      pthread_rwlock_unlock(&self.safe.lock)
      return result
    }

    /// Assign a brand new value to the wrapped object in a thread safe manner.
    ///
    /// - Parameter object: The replacement object.
    public func assign(_ object: T) {
      pthread_rwlock_wrlock(&self.safe.lock);
      self.safe.value = object
      pthread_rwlock_unlock(&self.safe.lock)
    }
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
