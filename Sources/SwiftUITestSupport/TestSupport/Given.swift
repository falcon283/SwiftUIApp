public import SwiftUI
private import OSLog
private import SwiftAppUtilities

private enum GivenError: Error, CustomDebugStringConvertible {
  case missingInjection(keys: [String])
  case missingCoreDataInjection

  var debugDescription: String {
    switch self {
    case let .missingInjection(keys):
      "Missing injection for keys: \(keys)"

    case .missingCoreDataInjection:
      "Missing CoreData injection"
    }
  }
}

@MainActor
public func given<V: View>(
  _ sut: @autoclosure () -> V,
  withDependencies injectDependencies: (inout Injector) async throws -> Void = { _ in },
  expect: @MainActor (V) async throws -> Void
) async throws {

#if canTestSwiftUI
  var injector = Injector()
  try await injectDependencies(&injector)

  let observation = startObservingMissingInjectionNotifications()
  defer { observation.unregisterNotifications() }

  try await TestSupport.execute(with: injector.storage) {
    try await expect(sut())
  }

  guard observation.missingInjectionKeys.isEmpty
  else { throw GivenError.missingInjection(keys: observation.missingInjectionKeys) }

  guard observation.missingCoreDataInjection == false
  else { throw GivenError.missingCoreDataInjection }
#else
  if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
    Logger(subsystem: "SwiftUITestSupport", category: "Given")
      .debug("⚠️ SwiftUITestSupport is disabled. Given expect closure call has been suppressed.")
  } else {
    os_log(
      .debug,
      log: OSLog(subsystem: "SwiftUITestSupport", category: "Given"),
      "⚠️ SwiftUITestSupport is disabled. Given expect closure call has been suppressed."
    )
  }
  return
#endif
}

// MARK: - Private NotificationCenter Helper

private struct InjectionNotificationObservation {
  private let _missingInjectionKeys: () -> [String]
  var missingInjectionKeys: [String] {
    self._missingInjectionKeys()
  }

  private let _missingCoreDataInjection: () -> Bool
  var missingCoreDataInjection: Bool {
    _missingCoreDataInjection()
  }

  let unregisterNotifications: () -> Void

  init(
    missingInjectionKeys: @escaping () -> [String],
    missingCoreDataInjection: @escaping () -> Bool,
    unregisterNotifications: @escaping () -> Void
  ) {
    self._missingInjectionKeys = missingInjectionKeys
    self._missingCoreDataInjection = missingCoreDataInjection
    self.unregisterNotifications = unregisterNotifications
  }
}

private func startObservingMissingInjectionNotifications() -> InjectionNotificationObservation {
  @ThreadSafe
  var missingInjectionKeys: [String] = []

  @ThreadSafe
  var missingCoreDataInjection = false

  let injectionToken = NotificationCenter.default
    .addObserver(
      forName: .swiftUITestSupportMissingInjection,
      object: nil,
      queue: nil
    ) { [criticalSection = $missingInjectionKeys] notification in
      criticalSection.perform {
        $0.append(
          notification.userInfo?[Notification.swiftUITestSupportMissingInjectionKeyDescription] as? String ?? "Unknown Key"
        )
      }
  }

  let coreDataToken = NotificationCenter.default
    .addObserver(
      forName: .swiftUITestSupportMissingCoreDataInjection,
      object: nil,
      queue: nil
    ) { [criticalSection = $missingCoreDataInjection] _ in
      criticalSection.assign(true)
  }

  return InjectionNotificationObservation {
    _missingInjectionKeys.wrappedValue
  } missingCoreDataInjection: {
    _missingCoreDataInjection.wrappedValue
  } unregisterNotifications: {
    NotificationCenter.default.removeObserver(injectionToken)
    NotificationCenter.default.removeObserver(coreDataToken)
  }
}
