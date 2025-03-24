public import CoreData
public import SwiftUI
internal import SwiftAppUtilities

extension Notification.Name {
  static let swiftUITestSupportMissingInjection = Notification.Name("_SwiftUIAppTestSupport_MissingInjection")
}

extension Notification {
  static let swiftUITestSupportMissingInjectionKeyDescription = "_SwiftUITestSupportMissingInjectionKeyDescription"
}

/// The injector object is used to support dependency injection while running Unit Tests.
///
/// You never create an Injector object but rather you receive it when using ``given(_:withDependencies:expect:)``.
/// The `given` function will setup the environment so that all the SwiftUI Shadows will be able to gather the configured injections.
public struct Injector: Sendable {

  @ThreadSafe
  private(set) var storage: [String: Any] = [TestSupport.unitTestKey: true]
  
  /// This method could be used in the remote possibility you are extending `Injector` because your codebase implements a custom `DynamicProperty`
  /// property wrapper and you want to enable it for Unit Testing purpose.
  ///
  /// This will be needed because `DynamicProperty` is a very special type in SwiftUI which is made accessible only in the View body. If not it will give you
  /// a runtime warning if inspected during Unit Tests.
  /// If you fall into this case, your implementation should also leverage ``TestSupport/isRunningUnitTest``.
  ///
  /// - Parameters:
  ///   - value: The value to inject.
  ///   - key: The key used to associate the object.
  ///
  /// - Note: If your custom `DynamicProperty` implementation is using `@Environment` `@EnvironmentObject` or any other provided shadows,
  /// they will be automatically shadowed so you don't have to care about them unless you explicitly use `@SwiftUI.Environment`.
  public nonmutating func inject<T>(_ value: T, for key: String) {
    self.storage[key] = value
  }
}

// MARK: - Environment

public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `EnvironmentValues` keyPath into the Shadows.
  ///
  /// - Parameters:
  ///   - keyPath: The keyPath for the injection. Must be exactly the same as the one used in your implementation.
  ///   - value: The value to inject
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `keyPath` as the implementation.
  /// If not the test will fail and will point you out the missing keyPath.
  @discardableResult
  nonmutating func environment<T>(_ keyPath: KeyPath<EnvironmentValues, T>, _ value: T) -> Injector {
    let key = TestSupport.environmentKey(for: keyPath)
    self.inject(value, for: key)
    return self
  }
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `Observable` into the Shadows.
  ///
  /// - Parameter observable: The `Observable` to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `T` as the implementation.
  /// If not the test will fail and will point you out the missing type..
  @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
  @discardableResult
  nonmutating func environment<T: Observable & AnyObject>(_ observable: T) -> Injector {
    let key = TestSupport.environmentKey(for: T.self)
    let keyOptional = TestSupport.environmentKey(for: T?.self)
    self.inject(observable, for: key)
    self.inject(observable, for: keyOptional)
    return self
  }
}

// MARK: - EnvironmentObject

public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `ObservableObject` into the Shadows.
  ///
  /// - Parameter object: The `ObservableObject` to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `T` as the implementation.
  /// If not the test will fail and will point you out the missing type..
  @discardableResult
  nonmutating func environmentObject<T: ObservableObject>(_ object: T) -> Injector {
    let key = TestSupport.environmentObjectKey(for: T.self)
    self.inject(object, for: key)
    return self
  }
}

// MARK: - Storage

public extension Injector {

  /// This is used to inject a value retrieved by ``AppStorage`` or ``SceneStorage`` Shadows.
  ///
  /// The injected value mimic a different value into `UserDefault`. If present the ``AppStorage`` and ``SceneStorage``
  /// will prefer the injected value over the default value as it would happen in real case scenario.
  ///
  /// - Parameter value: The object to inject.
  /// - Parameter key: The storage key of the ``AppStorage`` or ``SceneStorage``.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Note: The injected value type is inferred. Make sure to inject the proper one if you are using type inference.
  /// As example if you inject `.storage(1, for: "doubleKey")` the value inferred is `Int` and thus if the implementation key is expecting Double
  /// the injection lookup will fail. In this case you should inject `1.0` or `Double(1)` instead.
  ///
  /// - Warning: You must use exactly the same `key` as the implementation.
  @discardableResult
  nonmutating func storage<T>(_ value: T, for key: String) -> Injector {
    let key = TestSupport.storageKey(for: key)
    self.inject(value, for: key)
    return self
  }
}
