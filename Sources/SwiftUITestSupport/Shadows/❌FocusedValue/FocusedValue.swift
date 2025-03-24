public import SwiftUI
private import SwiftAppUtilities

/// A property wrapper for observing values from the focused view or one of its
/// ancestors.
///
/// If multiple views publish values using the same key, the wrapped property
///  will reflect the value from the view closest to focus.
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
@propertyWrapper public struct FocusedValue<Value> : DynamicProperty {

  private var storage: SwiftUI.FocusedValue<Value>

  private let retrievalKey: String

  /// A new property wrapper for the given key path.
  ///
  /// The value of the property wrapper is updated dynamically as focus
  /// changes and different published values go in and out of scope.
  ///
  /// - Parameter keyPath: The key path for the focus value to read.
  public init(_ keyPath: KeyPath<FocusedValues, Value?>) {
    self.storage = SwiftUI.FocusedValue(keyPath)
    self.retrievalKey = TestSupport.focusedValueKey(for: keyPath)
  }

  /// The value for the focus key given the current scope and state of the
  /// focused view hierarchy.
  ///
  /// Returns `nil` when nothing in the focused view hierarchy exports a
  /// value.
  public var wrappedValue: Value? {
    guard TestSupport.isRunningUnitTest else { return self.storage.wrappedValue }
    return TestSupport.getInjected(for: self.retrievalKey)
  }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension FocusedValue {

  /// A new property wrapper for the given object type.
  ///
  /// Reads the focused value of the given object type.
  ///
  /// - Important: This initializer only accepts objects conforming to the
  ///   `Observable` protocol. For reading environment objects that conform to
  ///   `ObservableObject`, use `FocusedObject`, instead.
  ///
  /// To set the focused value that is read by this, use the `focusedValue(_:)` view modifier.
  ///
  /// - Parameter objectType: The type of object to read the focus value for.
  public init(_ objectType: Value.Type) where Value : AnyObject, Value : Observable {
    self.storage = SwiftUI.FocusedValue(objectType)
    self.retrievalKey = TestSupport.focusedValueKey(for: Value.self)
  }
}
