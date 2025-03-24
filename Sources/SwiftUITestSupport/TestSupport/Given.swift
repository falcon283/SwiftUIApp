public import SwiftUI
private import SwiftAppUtilities

private enum GivenError: Error, CustomDebugStringConvertible {
  case missingInjection(keys: [String])

  var debugDescription: String {
    switch self {
    case let .missingInjection(keys):
      "Missing injection for keys: \(keys)"
    }
  }
}

/// An Helper function designed for Unit Testing execution.
///
/// When you a UIFeature is meant to be Unit Tested, It's required to execute the test code wrapped into a ``given(_:withDependencies:expect:)`` call.
///
/// - Parameters:
///   - sut: The System Under Test.
///   - injectDependencies: The Injector object you can use to alter the dependencies.
///   - expect: The actual test to run.
/// - Throws: Throws an error if the given expect function throws an error.
@MainActor
public func given<V: View>(
  _ sut: @autoclosure () -> V,
  withDependencies injectDependencies: (inout Injector) async -> Void = { _ in },
  expect: (V) async throws -> Void
) async throws {

  var injector = Injector()
  await injectDependencies(&injector)

  let observation = startObservingMissingInjectionNotifications()
  defer { observation.unregisterNotifications() }

  try await TestSupport.execute(with: injector.storage) {
    try await expect(sut())
  }

  guard observation.missingInjectionKeys.isEmpty
  else { throw GivenError.missingInjection(keys: observation.missingInjectionKeys) }
}

// MARK: - Private NotificationCenter Helper

private struct InjectionNotificationObservation {
  private let _missingInjectionKeys: () -> [String]
  var missingInjectionKeys: [String] {
    self._missingInjectionKeys()
  }

  let unregisterNotifications: () -> Void

  init(
    missingInjectionKeys: @escaping () -> [String],
    unregisterNotifications: @escaping () -> Void
  ) {
    self._missingInjectionKeys = missingInjectionKeys
    self.unregisterNotifications = unregisterNotifications
  }
}

private func startObservingMissingInjectionNotifications() -> InjectionNotificationObservation {
  @ThreadSafe
  var missingInjectionKeys: [String] = []

  let injectionToken = NotificationCenter.default
    .addObserver(
      forName: .swiftUITestSupportMissingInjection,
      object: nil,
      queue: nil
    ) { [_missingInjectionKeys] notification in
      _missingInjectionKeys.wrappedValue.append(
        notification.userInfo?[Notification.swiftUITestSupportMissingInjectionKeyDescription] as? String ?? "Unknown Key"
      )
  }

  return InjectionNotificationObservation {
    _missingInjectionKeys.wrappedValue
  } unregisterNotifications: {
    NotificationCenter.default.removeObserver(injectionToken)
  }
}
