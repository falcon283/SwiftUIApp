private import Foundation

public extension ViewModelFeature {

  func notify(_ event: UIEvent, storeIn bag: CancellationBag, withId cancellationId: AnyHashable? = nil) {
    let id = cancellationId ?? Self.cancellationId(for: event)

    Task { [weak bag] in
      await self.notify(event)
      guard !Task.isCancelled else { return }
      bag?.remove(id: id)
    }
    .store(in: bag, with: id)
  }
}

extension ViewModelFeature {

  static func cancellationId(for event: UIEvent) -> AnyHashable {
    (event as? any Identifiable).map { self.extractIdentifiableId(for: $0) } ??
    self.eventDescription(for: event).map(AnyHashable.init) ??
    AnyHashable(UUID())
  }

  private static func extractIdentifiableId<Event: Identifiable>(for event: Event) -> AnyHashable {
    event.id
  }
}

extension ViewModelFeature {

  static func eventDescription(for event: UIEvent) -> String? {
    _eventDescription(for: event, useParenthesisForSimpleType: false)
  }

  private static func _eventDescription(for item: Any, useParenthesisForSimpleType: Bool) -> String? {
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
        let associatedValues = (mirror.children.first?.value).flatMap { _eventDescription(for: $0, useParenthesisForSimpleType: true) } ?? ""
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
