public import SwiftUI
private import SwiftAppUtilities

/// A property wrapper type for an observable object that a parent or ancestor
/// view supplies.
///
/// An environment object invalidates the current view whenever the observable
/// object that conforms to
/// <https://developer.apple.com/documentation/Combine/ObservableObject>
/// changes. If you declare a property as an environment object, be sure
/// to set a corresponding model object on an ancestor view by calling its
/// `View/environmentObject(_:)` modifier.
///
/// > Note: If your observable object conforms to the
/// <https://developer.apple.com/documentation/Observation/Observable>
/// protocol, use ``Environment`` instead of `EnvironmentObject` and set the
/// model object in an ancestor view by calling its ``View/environment(_:)``
/// or `View/environment(_:_:)` modifiers.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@MainActor @propertyWrapper @preconcurrency public struct EnvironmentObject<ObjectType> : DynamicProperty where ObjectType : ObservableObject {

  private var storage: SwiftUI.EnvironmentObject<ObjectType>

  private let retrievalKey: String

  /// The underlying value referenced by the environment object.
  ///
  /// This property provides primary access to the value's data. However, you
  /// don't access `wrappedValue` directly. Instead, you use the property
  /// variable created with the ``EnvironmentObject`` attribute.
  ///
  /// When a mutable value changes, the new value is immediately available.
  /// However, a view displaying the value is updated asynchronously and may
  /// not show the new value immediately.
  @MainActor @preconcurrency public var wrappedValue: ObjectType {
    guard TestSupport.isRunningUnitTest else { return self.storage.wrappedValue }

    if let value: ObjectType = TestSupport.getInjected(for: self.retrievalKey) { return value }

    NotificationCenter.default.post(
      name: .swiftUITestSupportMissingInjection,
      object: nil,
      userInfo: [Notification.swiftUITestSupportMissingInjectionKeyDescription: self.retrievalKey]
    )
    return self.storage.wrappedValue
  }

  /// Creates an environment object.
  @MainActor @preconcurrency public init() {
    self.storage = SwiftUI.EnvironmentObject()
    self.retrievalKey = TestSupport.environmentObjectKey(for: ObjectType.self)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentObject : Sendable {}
