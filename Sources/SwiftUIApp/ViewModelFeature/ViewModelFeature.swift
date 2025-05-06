
/// The `ViewModelFeature` protocol is meant to be used when creating a UI with a standard `MVVM` pattern.
///
/// This is suitable for `UIKit` and `SwiftUI`, but for the latter one you are encouraged to use ``ViewFeature`` instead so to make the codebase
/// more concise by leveraging `SwiftUITestSupport`.
///
/// The `ViewModelFeature` instance is typically owned by the UI.
/// The UI uses the `ViewModelFeature` to ``notify(_:)-2iw5n`` events happened on the UI so that the `ViewModelFeature` can
/// react and schedule asynchronous work.
/// Usually the UI is running on the Main Thread and action are mean to be executed from a **synchronous context** meaning you typically not already in
/// an `async` context.
/// Due to this, an helper is available in such cases so to keep track of the asynchronous work and allow easy task cancellation when appropriate.
///
/// - Warning: Never make a `ViewModelFeature` owning a property of type ``CancellationBag`` which you use to keep track of the
/// task cancellations.
/// Doing so you will end up in possible retain cycles and surely prolonging the lifetime of the `ViewModelFeature` which will be destroyed only after the
/// `Task` completes.
/// Always use the ``CancellationBag`` of the UI so to avoid such issues.
@MainActor
public protocol ViewModelFeature {

  /// This event is what drives your Feature in terms of side effects.
  ///
  /// The best way to define the `UIEvent` is using an enumeration with associated types.
  /// There are no limitations on the type of `UIEvent` so there might be out there cases where it makes sense for the UIEvent not to be an enumeration.
  ///
  /// `UIEvent` is `Never` by default so to have zero effort to conform the `ViewModelFeature` protocol.
  ///  You might have a `ViewModelFeature` that just present data and does not require any UIEvent.
  ///  As soon as you have the needs to add events, just associated a type and you will be required to implement the ``notify(_:)-2iw5n``.
  ///
  /// ```swift
  ///  enum UIEvent {
  ///    case buttonTapped
  ///    case textChanged(String)
  ///  }
  /// ```
  associatedtype UIEvent = Never

  /// This method is meant to be called by your UI implementation so to communicate the `ViewModelFeature` what is the event to notify.
  ///
  /// The event is generally sent from interaction points such as  View loaded, Button taps, Gestures completions, and similar.
  ///
  /// You are required to implement this method as soon as you associate a type to ``UIEvent``.
  /// The implementation is supposed to switch the input event and do meaningful asynchronous work so to generate side effects to the `ViewModelFeature`
  /// presentation model which is observed by the UI implementation so to update the UI.
  ///
  /// - Parameter event: The event for which the specific Business Logic is requested to be executed.
  nonmutating func notify(_ event: UIEvent) async
}

public extension ViewModelFeature where UIEvent == Never {
  
  /// This default implementation is used to automatically conform `ViewModelFeature` implementer with zero effort.
  ///
  /// Whenever you are ready to add concrete events you can provide a `UIEvent` and then implement your specific ``notify(_:)-2iw5n`` function.
  nonmutating func notify(_ event: UIEvent) async { }
}
