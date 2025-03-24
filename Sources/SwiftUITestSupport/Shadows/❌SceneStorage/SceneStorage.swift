public import SwiftUI
internal import SwiftAppUtilities

/// A property wrapper type that reads and writes to persisted, per-scene
/// storage.
///
/// You use `SceneStorage` when you need automatic state restoration of the
/// value.  `SceneStorage` works very similar to `State`, except its initial
/// value is restored by the system if it was previously saved, and the value is
/// shared with other `SceneStorage` variables in the same scene.
///
/// The system manages the saving and restoring of `SceneStorage` on your
/// behalf. The underlying data that backs `SceneStorage` is not available to
/// you, so you must access it via the `SceneStorage` property wrapper. The
/// system makes no guarantees as to when and how often the data will be
/// persisted.
///
/// Each `Scene` has its own notion of `SceneStorage`, so data is not shared
/// between scenes.
///
/// Ensure that the data you use with `SceneStorage` is lightweight. Data of a
/// large size, such as model data, should not be stored in `SceneStorage`, as
/// poor performance may result.
///
/// If the `Scene` is explicitly destroyed (e.g. the switcher snapshot is
/// destroyed on iPadOS or the window is closed on macOS), the data is also
/// destroyed. Do not use `SceneStorage` with sensitive data.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper public struct SceneStorage<Value> : DynamicProperty {

  private var storage: SwiftUI.SceneStorage<Value>

  private enum TestValue {
    case defaultValue(Value)
    case updatedValue(Value)
  }

  private let retrievalKey: String

  @ThreadSafe
  private var testValue: TestValue

  /// The underlying value referenced by the state variable.
  ///
  /// This works identically to `State.wrappedValue`.
  ///
  /// - SeeAlso: State.wrappedValue
  public var wrappedValue: Value {
    get {
      guard TestSupport.isRunningUnitTest else { return self.storage.wrappedValue }

      switch self.testValue {
      case let .defaultValue(value):
        return TestSupport.getInjected(for: self.retrievalKey) ?? value

      case let .updatedValue(value):
        return value
      }
    }
    nonmutating set {
      if TestSupport.isRunningUnitTest {
        self.testValue = .updatedValue(newValue)
      } else {
        self.storage.wrappedValue = newValue
      }
    }
  }
}

@available(iOS 17.0, macOS 14.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension SceneStorage {

  /// Creates a property that can save and restore table column state.
  ///
  /// - Parameter wrappedValue: The default value if table column state is not
  ///   available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init<RowValue>(wrappedValue: Value = TableColumnCustomization<RowValue>(), _ key: String) where Value == TableColumnCustomization<RowValue>, RowValue : Identifiable {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension SceneStorage : @unchecked Sendable where Value : Sendable {
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension SceneStorage {

  /// Creates a property that can save and restore a boolean.
  ///
  /// - Parameter wrappedValue: The default value if a boolean is not
  ///   available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == Bool {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an integer.
  ///
  /// - Parameter wrappedValue: The default value if an integer is not
  ///   available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == Int {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore a double.
  ///
  /// - Parameter wrappedValue: The default value if a double is not available
  ///   for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == Double {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore a string.
  ///
  /// - Parameter wrappedValue: The default value if a string is not available
  ///   for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == String {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore a URL.
  ///
  /// - Parameter wrappedValue: The default value if a URL is not available
  ///   for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == URL {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore a Date.
  ///
  /// - Parameter wrappedValue: The default value if a Date is not available
  ///   for the given key.
  /// - Parameter key: a key used to save and restore the value.
  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  public init(wrappedValue: Value, _ key: String) where Value == Date {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore data.
  ///
  /// Avoid storing large data blobs, such as image data, as it can negatively
  /// affect performance of your app.
  ///
  /// - Parameter wrappedValue: The default value if data is not available
  ///   for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value == Data {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an integer, transforming it
  /// to a `RawRepresentable` data type.
  ///
  /// A common usage is with enumerations:
  ///
  /// ```swift
  ///     enum MyEnum: Int {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @SceneStorage("MyEnumValue") private var value = MyEnum.a
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameter wrappedValue: The default value if an integer value is not
  ///   available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value : RawRepresentable, Value.RawValue == Int {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore a string, transforming it
  /// to a `RawRepresentable` data type.
  ///
  /// A common usage is with enumerations:
  ///
  /// ```swift
  ///     enum MyEnum: String {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @SceneStorage("MyEnumValue") private var value = MyEnum.a
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameter wrappedValue: The default value if a String value is not
  ///   available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value, _ key: String) where Value : RawRepresentable, Value.RawValue == String {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension SceneStorage where Value : ExpressibleByNilLiteral {

  /// Creates a property that can save and restore an Optional boolean.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == Bool? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional integer.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == Int? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional double.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == Double? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional string.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == String? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional URL.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == URL? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional Date.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  public init(_ key: String) where Value == Date? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional data.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init(_ key: String) where Value == Data? {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension SceneStorage {

  /// Creates a property that can save and restore an Optional string,
  /// transforming it to an Optional `RawRepresentable` data type.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// A common usage is with enumerations:
  ///
  /// ```swift
  ///     enum MyEnum: String {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @SceneStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init<R>(_ key: String) where Value == R?, R : RawRepresentable, R.RawValue == String {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can save and restore an Optional integer,
  /// transforming it to an Optional `RawRepresentable` data type.
  ///
  /// Defaults to nil if there is no restored value
  ///
  /// A common usage is with enumerations:
  ///
  /// ```swift
  ///     enum MyEnum: Int {
  ///         case a
  ///         case b
  ///         case c
  ///     }
  ///     struct MyView: View {
  ///         @SceneStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameter key: a key used to save and restore the value.
  public init<R>(_ key: String) where Value == R?, R : RawRepresentable, R.RawValue == Int {
    self.storage = SwiftUI.SceneStorage(key)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension SceneStorage {

  /// Creates a property that can save and restore tab sidebar customizations.
  ///
  /// You can set this customization on the TabView using
  /// ``View/tabViewCustomization(_:)``.
  ///
  /// The tab view customization is typically not added to
  /// `SceneStorage`, but instead stored in `AppStorage` so the
  /// customizations are consistent across different scenes.
  ///
  /// - Parameter wrappedValue: The default value if the customization
  ///   is not available for the given key.
  /// - Parameter key: a key used to save and restore the value.
  public init(wrappedValue: Value = TabViewCustomization(), _ key: String, store: UserDefaults? = nil) where Value == TabViewCustomization {
    self.storage = SwiftUI.SceneStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}
