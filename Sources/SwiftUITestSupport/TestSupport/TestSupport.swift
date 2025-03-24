internal import Foundation
private import SwiftAppUtilities

/// A namespace used to encapsulated some utilities.
public enum TestSupport {

  static let unitTestKey = UUID().uuidString

  @TaskLocal
  private static var storage: [String: ThreadSafe<Any>] = [:]

  /// This method is an helper that should be used only in case you are writing your custom DynamicProperty.
  ///
  /// Within the implementation of your custom `DynamicProperty` you will access the TaskLocal storage which contains what has been injected by the ``given(_:withDependencies:expect:)`` during Unit Test.
  ///
  /// See also ``Injector/inject(_:for:)``.
  ///
  /// - Parameter key: The key to lookup for the object.
  /// - Returns: The associated object if injected properly.
  public static func getInjected<T>(for key: String) -> T? {
    self.storage[key]?.wrappedValue as? T
  }

  static func execute(
    with storage: [String: Any],
    operation: () async throws -> Void,
    isolation: isolated (any Actor)? = #isolation,
    file: String = #fileID,
    line: UInt = #line
  ) async rethrows {
    try await self.$storage.withValue(
      storage.mapValues { ThreadSafe($0) },
      operation: operation,
      isolation: isolation,
      file: file,
      line: line
    )
  }
  
  /// This function always return `false` unless you are running inside a ``given(_:withDependencies:expect:)`` expect closure.
  public static var isRunningUnitTest: Bool {
    guard let threadSafe = self.storage[self.unitTestKey],
          let value = threadSafe.wrappedValue as? Bool,
          value == true else { return false }
    return true
  }
}
