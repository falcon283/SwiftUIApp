internal import SwiftAppUtilities

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
