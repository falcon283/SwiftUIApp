private import Foundation

/// A protocol meant to provide a human readable name to identify each enumeration case.
///
/// As example
/// ```swift
/// enum MyEnum: NamedEvent {
///   case foo
///   case bar(value: Int)
///
///   var caseName: String {
///     switch self {
///     case .foo: return ".foo"
///     case .bar: return ".bar(value: Int)"
///     }
///   }
/// }
/// ```
///
/// - Note: The `caseName` of each case should not contain the associated value but rather just the `Type` of the associated value.
public protocol NamedEvent {
  var caseName: String { get }
}

public extension ViewModelFeature {

  /// This method is meant to be called by the UI implementation so to communicate the `ViewModelFeature` what is the event to notify.
  ///
  /// The event is generally sent from interaction points such as  View loaded, Button taps, Gestures completions, and similar.
  ///
  /// If calling this function you don't pass a `cancellationId`, the implementation creates an `Id` on its own using the following logic:
  /// - Extract `UIEvent.id` if `UIEvent` is `Identifiable`
  /// - Extract `UIEvent.caseName` if `UIEvent` is `NamedEvent`
  /// - Extract the `id` from the `UIEvent` `Type` by using `Mirror`. Embedded values such as variables values or associated
  ///   type values are ignored and only the `Types` are taken into account to determine the `id`.
  /// - If all the above fail a `UUID` is generated instead.
  ///
  /// - Note: This method is an helper to shortcut usages of ``notify(_:)-2iw5n`` in synchronous contexts.
  /// Calling this method is equivalent of calling the async counterpart wrapped in a `Task { ... }` and stored into the injected bag. This is particularly useful
  /// to use where an `async` context is not available.
  ///
  /// - Parameter event: The event for which the specific Business Logic is requested to be executed.
  /// - Parameter bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  /// - Parameter cancellationId: An optional id to keep track of the cancellation.
  /// If you don't pass an id, an internal one gets generated on the event basis.
  ///
  /// - Note: For maximum control over cancellation and assure it's 100% deterministic it's highly recommended to inject your own `cancellationId`.
  /// If your `UIEvent` conforms to `Identifiable` or `NamedEvent` you can omit `withId` parameter and the corresponding `cancellationId`
  /// is extracted with not runtime cost.
  func notify(_ event: UIEvent, storeIn bag: CancellationBag, withId cancellationId: AnyHashable? = nil) {
    let id = cancellationId ?? Self.eventIdentifier(for: event)

    Task { [weak bag] in
      await self.notify(event)
      guard !Task.isCancelled else { return }
      bag?.remove(id: id)
    }
    .store(in: bag, with: id)
  }

  /// This method is meant to be called by the UI implementation so to communicate the `ViewModelFeature` what is the event to notify.
  ///
  /// The event is generally sent from interaction points such as  View loaded, Button taps, Gestures completions, and similar.
  ///
  /// - Note: This method is an helper to shortcut usages of ``notify(_:)-2iw5n`` in synchronous contexts.
  /// Calling this method is equivalent of calling the async counterpart wrapped in a `Task { ... }` and stored into the injected bag. This is particularly useful
  /// to use where an `async` context is not available.
  ///
  /// - Parameter event: The event for which the specific Business Logic is requested to be executed.
  /// - Parameter bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  /// If you don't pass an id, an internal one gets generated on the event basis.
  func notify(_ event: UIEvent, storeIn bag: CancellationBag) where UIEvent: Identifiable {
    self.notify(event, storeIn: bag, withId: event.id)
  }

  /// This method is meant to be called by the UI implementation so to communicate the `ViewModelFeature` what is the event to notify.
  ///
  /// The event is generally sent from interaction points such as  View loaded, Button taps, Gestures completions, and similar.
  ///
  /// - Note: This method is an helper to shortcut usages of ``notify(_:)-2iw5n`` in synchronous contexts.
  /// Calling this method is equivalent of calling the async counterpart wrapped in a `Task { ... }` and stored into the injected bag. This is particularly useful
  /// to use where an `async` context is not available.
  ///
  /// - Parameter event: The event for which the specific Business Logic is requested to be executed.
  /// - Parameter bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  /// If you don't pass an id, an internal one gets generated on the event basis.
  func notify(_ event: UIEvent, storeIn bag: CancellationBag) where UIEvent: NamedEvent {
    self.notify(event, storeIn: bag, withId: event.caseName)
  }

  /// This method is meant to be called by the UI implementation so to communicate the `ViewModelFeature` what is the event to notify.
  ///
  /// The event is generally sent from interaction points such as  View loaded, Button taps, Gestures completions, and similar.
  ///
  /// - Note: This method is an helper to shortcut usages of ``notify(_:)-2iw5n`` in synchronous contexts.
  /// Calling this method is equivalent of calling the async counterpart wrapped in a `Task { ... }` and stored into the injected bag. This is particularly useful
  /// to use where an `async` context is not available.
  ///
  /// - Parameter event: The event for which the specific Business Logic is requested to be executed.
  /// - Parameter bag: The ``CancellationBag`` of the UI used to keep track of the asynchronous work.
  /// If you don't pass an id, an internal one gets generated on the event basis.
  func notify(_ event: UIEvent, storeIn bag: CancellationBag) where UIEvent: NamedEvent & Identifiable {
    self.notify(event, storeIn: bag, withId: event.caseName)
  }
}

extension ViewModelFeature {

  static func eventIdentifier(for event: UIEvent) -> AnyHashable {
    (event as? any Identifiable).map { self.extractIdentifiableId(for: $0) } ??
    (event as? any NamedEvent).map { $0.caseName } ??
    self.nonConformingEventDescription(for: event).map(AnyHashable.init) ??
    AnyHashable(UUID())
  }

  private static func extractIdentifiableId<Event: Identifiable>(for event: Event) -> AnyHashable {
    event.id
  }
}

private extension ViewModelFeature {

  static func nonConformingEventDescription(for event: UIEvent) -> String? {
    self.eventDescription(for: event, useParenthesisForSimpleType: false)
  }

  static func eventDescription(for item: Any, useParenthesisForSimpleType: Bool) -> String? {
    let mirror = Mirror(reflecting: item)

    guard let displayStyle = mirror.displayStyle else {
      return useParenthesisForSimpleType ? "(.0: \(mirror.subjectType))" : "\(mirror.subjectType)"
    }

    switch displayStyle {
    case .struct, .class:
      let properties = mirror.children.compactMap { child -> String? in
        return [child.label, "\(type(of: child.value))"].compactMap { $0 }.joined(separator: ": ")
      }
      return "\(UIEvent.self) { \(properties.joined(separator: "; ")) }"

    case .enum:
      if let caseName = mirror.children.first?.label {
        let associatedValues = (mirror.children.first?.value).flatMap { self.eventDescription(for: $0, useParenthesisForSimpleType: true) } ?? ""
        return ".\(caseName)\(associatedValues)"
      } else {
        return ".\(item)"
      }

    case .tuple:
      return "(\(mirror.children.enumerated().map { offset, child in [child.label ?? ".\(offset)", "\(type(of: child.value))"].compactMap { $0 }.joined(separator: ": ") }.joined(separator: ", ")))"

    case .optional,
         .collection,
         .dictionary,
         .set:
      return nil

    @unknown default:
      return nil
    }
  }
}
