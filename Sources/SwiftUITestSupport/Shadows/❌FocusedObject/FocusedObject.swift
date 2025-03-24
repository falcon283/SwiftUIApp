public import SwiftUI
private import SwiftAppUtilities

/// A property wrapper type for an observable object supplied by the focused
/// view or one of its ancestors.
///
/// Focused objects invalidate the current view whenever the observable object
/// changes. If multiple views publish a focused object using the same key, the
/// wrapped property will reflect the object that's closest to the focused view.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor @propertyWrapper @preconcurrency public struct FocusedObject<ObjectType> : DynamicProperty where ObjectType : ObservableObject {

  private var storage: SwiftUI.FocusedObject<ObjectType>

  private let retrievalKey: String

  /// The underlying value referenced by the focused object.
  ///
  /// This property provides primary access to the value's data. However, you
  /// don't access `wrappedValue` directly. Instead, you use the property
  /// variable created with the ``FocusedObject`` attribute.
  ///
  /// When a mutable value changes, the new value is immediately available.
  /// However, a view displaying the value is updated asynchronously and may
  /// not show the new value immediately.
  @MainActor @preconcurrency public var wrappedValue: ObjectType? {
    guard TestSupport.isRunningUnitTest else { return self.storage.wrappedValue }
    return TestSupport.getInjected(for: self.retrievalKey)
  }

  /// Creates a focused object.
  @MainActor @preconcurrency public init() {
    self.storage = SwiftUI.FocusedObject()
    self.retrievalKey = TestSupport.focusedObjectKey(for: ObjectType.self)
  }
}
