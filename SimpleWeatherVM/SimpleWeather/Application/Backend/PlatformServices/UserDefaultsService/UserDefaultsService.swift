import Foundation

struct UserDefaultsService: Sendable {

  private let get: @Sendable (String) -> Any?
  private let set: @Sendable (String, Any?) -> Void

  init(get: @escaping @Sendable (String) -> Any?, set: @escaping @Sendable (String, Any?) -> Void) {
    self.get = get
    self.set = set
  }

  func getValue<Value>(for key: String, defaultValue value: Value) -> Value {
    (self.get(key) as? Value) ?? value
  }

  nonmutating func setValue<Value>(_ value: Value, key: String) {
    self.set(key, value)
  }
}
