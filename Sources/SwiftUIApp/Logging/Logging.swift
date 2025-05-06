public import OSLog
public import SwiftUI

public enum Logging {

  /// The argument to be passed to enable the logging: `--SwiftUIAppDebugLogging`
  public static let debugLogArgumentKey = "--SwiftUIAppDebugLogging"

  /// The SwiftUIApp `Logger` from `OSLog` module.
  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  public static let swiftUIAppUIEventLogger: Logger = {
    if ProcessInfo.processInfo.arguments.contains(debugLogArgumentKey) {
      return Logger(subsystem: "SwiftUIApp", category: "UIEvent")
    } else {
      return Logger(.disabled)
    }
  }()

  /// The SwiftUIApp legacy `OSLog` from `OSLog` module.
  ///
  /// @DeprecationSummary {
  ///   Use ``swiftUIAppUIEventLogger``
  /// }
  @available(macOS, deprecated: 11.0, renamed: "swiftUIAppUIEventLogger")
  @available(iOS, deprecated: 14.0, renamed: "swiftUIAppUIEventLogger")
  @available(watchOS, deprecated: 7.0, renamed: "swiftUIAppUIEventLogger")
  @available(tvOS, deprecated: 14.0, renamed: "swiftUIAppUIEventLogger")
  public static let legacySwiftUIAppUIEventOSLogger: OSLog = {
    if ProcessInfo.processInfo.arguments.contains(debugLogArgumentKey) {
      return OSLog(subsystem: "SwiftUIApp", category: "UIEvent")
    } else {
      return .disabled
    }
  }()
}

public extension EnvironmentValues {
  
  /// The SwiftUIApp `Logger` from `OSLog` module.
  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  @Entry var uiEventLogger = Logging.swiftUIAppUIEventLogger

  /// The SwiftUIApp legacy `OSLog` from `OSLog` module.
  ///
  /// @DeprecationSummary {
  ///   Use ``uiEventLogger``
  /// }
  @available(macOS, deprecated: 11.0, renamed: "uiEventLogger")
  @available(iOS, deprecated: 14.0, renamed: "uiEventLogger")
  @available(watchOS, deprecated: 7.0, renamed: "uiEventLogger")
  @available(tvOS, deprecated: 14.0, renamed: "uiEventLogger")
  @Entry var legacyUIEventOSLogger = Logging.legacySwiftUIAppUIEventOSLogger
}

public extension ViewModelFeature {
  
  /// An helper to output a standardized log message suitable for logging.
  ///
  /// - Parameter event: The event to log.
  /// - Returns: A string that can be used as interpolation for logging purpose.
  ///
  /// ```swift
  /// @Environment(\.uiEventLogger)
  /// var log
  ///
  /// ...
  ///
  /// func notify(_ event: UIEvent) async {
  ///     self.log.debug("\(standardMessageFor(event))")
  ///
  ///     switch event {
  ///     ...
  ///     }
  /// }
  /// ```
  func standardMessageFor(_ event: UIEvent) -> String {
    return "\(Self.self) - notify(\(Self.eventDescription(for: event) ?? "\(UIEvent.self)")))"
  }
}
