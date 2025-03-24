public import SwiftUI
internal import SwiftAppUtilities

/// A property wrapper type that reflects a value from `UserDefaults` and
/// invalidates a view on a change in value in that user default.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper public struct AppStorage<Value> : DynamicProperty {

  private enum TestValue {
    case defaultValue(Value)
    case updatedValue(Value)
  }

  private var storage: SwiftUI.AppStorage<Value>

  private let retrievalKey: String

  @ThreadSafe
  private var testValue: TestValue

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
extension AppStorage {

  /// Creates a property that can save and restore table column state.
  ///
  /// Table column state is typically not bound from a table directly to
  /// `AppStorage`, but instead indirecting through `State` or `SceneStorage`,
  /// and using the app storage value as its initial value kept up to date
  /// on changes to the direct backing.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if table column state is not
  ///   available for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init<RowValue>(wrappedValue: Value = TableColumnCustomization<RowValue>(), _ key: String, store: UserDefaults? = nil) where Value == TableColumnCustomization<RowValue>, RowValue : Identifiable {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension AppStorage : Sendable where Value : Sendable {}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension AppStorage {

  /// Creates a property that can read and write to a boolean user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a boolean value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Bool {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to an integer user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Int {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a double user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a double value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Double {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a string user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value is not specified
  ///     for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == String {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a url user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a url value is not specified for
  ///     the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == URL {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a date user default.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a date value is not specified for
  ///     the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Date {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a user default as data.
  ///
  /// Avoid storing large data blobs in user defaults, such as image data,
  /// as it can negatively affect performance of your app. On tvOS, a
  /// `NSUserDefaultsSizeLimitExceededNotification` notification is posted
  /// if the total user default size reaches 512kB.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a data value is not specified for
  ///    the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Data {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to an integer user default,
  /// transforming that to `RawRepresentable` data type.
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
  ///         @AppStorage("MyEnumValue") private var value = MyEnum.a
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if an integer value
  ///     is not specified for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == Int {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write to a string user default,
  /// transforming that to `RawRepresentable` data type.
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
  ///         @AppStorage("MyEnumValue") private var value = MyEnum.a
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if a string value
  ///     is not specified for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value : RawRepresentable, Value.RawValue == String {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension AppStorage where Value : ExpressibleByNilLiteral {

  /// Creates a property that can read and write an Optional boolean user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == Bool? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional integer user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == Int? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional double user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == Double? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional string user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == String? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional URL user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == URL? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional Date user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
  public init(_ key: String, store: UserDefaults? = nil) where Value == Date? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }

  /// Creates a property that can read and write an Optional data user
  /// default.
  ///
  /// Defaults to nil if there is no restored value.
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(_ key: String, store: UserDefaults? = nil) where Value == Data? {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AppStorage {

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
  ///         @AppStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init<R>(_ key: String, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == String {
    self.storage = SwiftUI.AppStorage(key, store: store)
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
  ///         @AppStorage("MyEnumValue") private var value: MyEnum?
  ///         var body: some View { ... }
  ///     }
  /// ```
  ///
  /// - Parameters:
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init<R>(_ key: String, store: UserDefaults? = nil) where Value == R?, R : RawRepresentable, R.RawValue == Int {
    self.storage = SwiftUI.AppStorage(key, store: store)
    self.testValue = .defaultValue(nil)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension AppStorage {

  /// Creates a property that can save and restore a toolbarLabelStyle state.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if toolbarLabelStyle state is not
  ///   available for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value = ToolbarLabelStyle.automatic, _ key: String, store: UserDefaults? = nil) where Value == ToolbarLabelStyle {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension AppStorage {

  /// Creates a property that can save and restore tab sidebar customizations.
  ///
  /// You can set this customization on the TabView using
  /// `tabViewCustomization(_:)`.
  ///
  /// - Parameters:
  ///   - wrappedValue: The default value if the customization is not
  ///   available for the given key.
  ///   - key: The key to read and write the value to in the user defaults
  ///     store.
  ///   - store: The user defaults store to read and write to. A value
  ///     of `nil` will use the user default store from the environment.
  public init(wrappedValue: Value = TabViewCustomization(), _ key: String, store: UserDefaults? = nil) where Value == TabViewCustomization {
    self.storage = SwiftUI.AppStorage(wrappedValue: wrappedValue, key, store: store)
    self.testValue = .defaultValue(wrappedValue)
    self.retrievalKey = TestSupport.storageKey(for: key)
  }
}
