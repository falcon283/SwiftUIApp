internal import Foundation
private import SwiftAppUtilities

public enum TestSupport {

  static let unitTestKey = UUID().uuidString
  static let persistentContainerKey = UUID().uuidString

  @TaskLocal
  private static var storage: [String: ThreadSafe<Any>] = [:]
  
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
  
  public static var isRunningUnitTest: Bool {
    guard let threadSafe = self.storage[self.unitTestKey],
          let value = threadSafe.wrappedValue as? Bool,
          value == true else { return false }
    return true
  }
}

extension TestSupport {

  static func environmentKey(for keyPath: AnyKeyPath) -> String {
    return "Environment_\(String(describing: keyPath))"
  }

  static func environmentKey<Value>(for valueType: Value.Type) -> String {
    "Environment_\(String(describing: valueType))"
  }

  static func environmentObjectKey<ObjectType>(for objectType: ObjectType.Type) -> String where ObjectType: ObservableObject {
    "EnvironmentObject_\(String(describing: objectType))"
  }

  static func storageKey(for storageKey: String) -> String {
    "Storage_\(storageKey)"
  }

  static func focusedObjectKey<ObjectType>(for objectType: ObjectType.Type) -> String where ObjectType: ObservableObject {
    "FocusedObject_\(String(describing: objectType))"
  }

  static func focusedValueKey(for keyPath: AnyKeyPath) -> String {
    "FocusedValue_\(String(describing: keyPath))"
  }

  static func focusedValueKey<Value>(for valueType: Value.Type) -> String {
    "FocusedValue_\(String(describing: valueType))"
  }
}
