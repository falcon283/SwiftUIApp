public import SwiftUI
private import SwiftAppUtilities

/// A property wrapper that reads a value from a view's environment.
///
/// Use the `Environment` property wrapper to read a value
/// stored in a view's environment. Indicate the value to read using an
/// `EnvironmentValues` key path in the property declaration. For example, you
/// can create a property that reads the color scheme of the current
/// view using the key path of the `colorScheme`
/// property:
///
/// ```swift
///     @Environment(\.colorScheme) var colorScheme: ColorScheme
/// ```
///
/// You can condition a view's content on the associated value, which
/// you read from the declared property's ``wrappedValue``. As with any property
/// wrapper, you access the wrapped value by directly referring to the property:
///
/// ```swift
///     if colorScheme == .dark { // Checks the wrapped value.
///         DarkContent()
///     } else {
///         LightContent()
///     }
/// ```
///
/// If the value changes, SwiftUI updates any parts of your view that depend on
/// the value. For example, that might happen in the above example if the user
/// changes the Appearance settings.
///
/// You can use this property wrapper to read --- but not set --- an environment
/// value. SwiftUI updates some environment values automatically based on system
/// settings and provides reasonable defaults for others. You can override some
/// of these, as well as set custom environment values that you define,
/// using the `environment(_:_:)` view modifier.
///
/// For the complete list of environment values SwiftUI provides, see the
/// properties of the `EnvironmentValues` structure. For information about
/// creating custom environment values, see the `Entry()` macro.
///
/// ### Get an observable object
///
/// You can also use `Environment` to get an observable object from a view's
/// environment. The observable object must conform to the
/// <https://developer.apple.com/documentation/observation/observable>
/// protocol, and your app must set the object in the environment using the
/// the object itself or a key path.
///
/// To set the object in the environment using the object itself, use the
/// `View/environment(_:)` modifier:
///
/// ```swift
///     @Observable
///     class Library {
///         var books: [Book] = [Book(), Book(), Book()]
///
///         var availableBooksCount: Int {
///             books.filter(\.isAvailable).count
///         }
///     }
///
///     @main
///     struct BookReaderApp: App {
///         @State private var library = Library()
///
///         var body: some Scene {
///             WindowGroup {
///                 LibraryView()
///                     .environment(library)
///             }
///         }
///     }
/// ```
///
/// To get the observable object using its type, create a property and provide
/// the `Environment` property wrapper the object's type:
///
/// ```swift
///     struct LibraryView: View {
///         @Environment(Library.self) private var library
///
///         var body: some View {
///             // ...
///         }
///     }
/// ```
///
/// By default, reading an object from the environment returns a non-optional
/// object when using the object type as the key. This default behavior assumes
/// that a view in the current hierarchy previously stored a non-optional
/// instance of the type using the `View/environment(_:)` modifier. If
/// a view attempts to retrieve an object using its type and that object isn't
/// in the environment, SwiftUI throws an exception.
///
/// In cases where there is no guarantee that an object is in the environment,
/// retrieve an optional version of the object as shown in the following code.
/// If the object isn't available the environment, SwiftUI returns `nil`
/// instead of throwing an exception.
///
/// ```swift
///     @Environment(Library.self) private var library: Library?
/// ```
///
/// ### Get an observable object using a key path
///
/// To set the object with a key path, use the `environment(_:_:)`
/// modifier:
///
/// ```swift
///     @Observable
///     class Library {
///         var books: [Book] = [Book(), Book(), Book()]
///
///         var availableBooksCount: Int {
///             books.filter(\.isAvailable).count
///         }
///     }
///
///     @main
///     struct BookReaderApp: App {
///         @State private var library = Library()
///
///         var body: some Scene {
///             WindowGroup {
///                 LibraryView()
///                     .environment(\.library, library)
///             }
///         }
///     }
/// ```
///
/// To get the object, create a property and specify the key path:
///
/// ```swift
///     struct LibraryView: View {
///         @Environment(\.library) private var library
///
///         var body: some View {
///             // ...
///         }
///     }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper public struct Environment<Value> : DynamicProperty {

  fileprivate var storage: SwiftUI.Environment<Value>

  private let retrievalKey: String

  /// Creates an environment property to read the specified key path.
  ///
  /// Don’t call this initializer directly. Instead, declare a property
  /// with the ``Environment`` property wrapper, and provide the key path of
  /// the environment value that the property should reflect:
  ///
  /// ```swift
  ///     struct MyView: View {
  ///         @Environment(\.colorScheme) var colorScheme: ColorScheme
  ///
  ///         // ...
  ///     }
  /// ```
  ///
  /// SwiftUI automatically updates any parts of `MyView` that depend on
  /// the property when the associated environment value changes.
  /// You can't modify the environment value using a property like this.
  /// Instead, use the `environment(_:_:)` view modifier on a view to
  /// set a value for a view hierarchy.
  ///
  /// - Parameter keyPath: A key path to a specific resulting value.
  public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
    self.storage = SwiftUI.Environment(keyPath)
    self.retrievalKey = TestSupport.environmentKey(for: keyPath)
  }

  /// The current value of the environment property.
  ///
  /// The wrapped value property provides primary access to the value's data.
  /// However, you don't access `wrappedValue` directly. Instead, you read the
  /// property variable created with the ``Environment`` property wrapper:
  ///
  /// ```swift
  ///     @Environment(\.colorScheme) var colorScheme: ColorScheme
  ///
  ///     var body: some View {
  ///         if colorScheme == .dark {
  ///             DarkContent()
  ///         } else {
  ///             LightContent()
  ///         }
  ///     }
  /// ```
  public var wrappedValue: Value {
    guard TestSupport.isRunningUnitTest else { return self.storage.wrappedValue }

    if let value: Value = TestSupport.getInjected(for: self.retrievalKey) { return value }

    NotificationCenter.default.post(
      name: .swiftUITestSupportMissingInjection,
      object: nil,
      userInfo: [Notification.swiftUITestSupportMissingInjectionKeyDescription: self.retrievalKey]
    )
    return self.storage.wrappedValue
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Environment : Sendable where Value : Sendable {}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Environment {

  /// Creates an environment property to read an observable object from the
  /// environment.
  ///
  /// - Important: This initializer only accepts objects conforming to the
  ///   `Observable` protocol. For reading environment objects that conform to
  ///   `ObservableObject`, use ``EnvironmentObject`` instead.
  ///
  /// Don’t call this initializer directly. Instead, declare a property with
  /// the ``Environment`` property wrapper, passing the object's type to the
  /// wrapper (using this syntax, the object type can be omitted from the end
  /// of property declaration):
  ///
  /// ```swift
  ///     @Observable final class Profile { ... }
  ///
  ///     struct MyView: View {
  ///         @Environment(Profile.self) private var currentProfile
  ///
  ///         // ...
  ///     }
  /// ```
  ///
  /// - Warning: If no object has been set in the view's environment, this
  /// property will issue a fatal error when accessed. To safely check for the
  /// existence of an environment object, initialize the environment property
  /// with an optional object type instead.
  ///
  /// SwiftUI automatically updates any parts of `MyView` that depend on the
  /// property when the associated environment object changes.
  ///
  /// You can't modify the environment object using a property like this.
  /// Instead, use the `View/environment(_:)` view modifier on a view
  /// to set an object for a view hierarchy.
  ///
  /// - Parameter objectType: The type of the `Observable` object to read
  ///   from the environment.
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  public init(_ objectType: Value.Type) where Value : AnyObject, Value : Observable {
    self.storage = SwiftUI.Environment(objectType)
    self.retrievalKey = TestSupport.environmentKey(for: Value.self)
  }

  /// Creates an environment property to read an observable object from the
  /// environment, returning `nil` if no corresponding object has been set in
  /// the current view's environment.
  ///
  /// - Important: This initializer only accepts objects conforming to the
  ///   `Observable` protocol. For reading environment objects that conform to
  ///   `ObservableObject`, use ``EnvironmentObject`` instead.
  ///
  /// Don’t call this initializer directly. Instead, declare an optional
  /// property with the ``Environment`` property wrapper, passing the object's
  /// type to the wrapper:
  ///
  /// ```swift
  ///     @Observable final class Profile { ... }
  ///
  ///     struct MyView: View {
  ///         @Environment(Profile.self) private var currentProfile: Profile?
  ///
  ///         // ...
  ///     }
  /// ```
  /// 
  /// If no object has been set in the view's environment, this property will
  /// return `nil` as its wrapped value.
  ///
  /// SwiftUI automatically updates any parts of `MyView` that depend on the
  /// property when the associated environment object changes.
  ///
  /// You can't modify the environment object using a property like this.
  /// Instead, use the `View/environment(_:)` view modifier on a view
  /// to set an object for a view hierarchy.
  ///
  /// - Parameter objectType: The type of the `Observable` object to read
  ///   from the environment.
  @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
  public init<T>(_ objectType: T.Type) where Value == T?, T : AnyObject, T : Observable {
    self.storage = SwiftUI.Environment(objectType)
    self.retrievalKey = TestSupport.environmentKey(for: T.self)
  }
}
