public import OSLog
public import SwiftUI

public enum Logging {

  public static let debugLogArgumentKey = "--SwiftUIAppDebugLogging"

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  public static let swiftUIAppUIEventLogger: Logger = {
    if ProcessInfo.processInfo.arguments.contains(debugLogArgumentKey) {
      return Logger(subsystem: "SwiftUIApp", category: "UIEvent")
    } else {
      return Logger(.disabled)
    }
  }()

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

  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  @Entry var uiEventLogger = Logging.swiftUIAppUIEventLogger

  @available(macOS, deprecated: 11.0, renamed: "uiEventLogger")
  @available(iOS, deprecated: 14.0, renamed: "uiEventLogger")
  @available(watchOS, deprecated: 7.0, renamed: "uiEventLogger")
  @available(tvOS, deprecated: 14.0, renamed: "uiEventLogger")
  @Entry var legacyUIEventOSLogger = Logging.legacySwiftUIAppUIEventOSLogger
}

public extension ViewModelFeature {
  
  func standardMessageFor(_ event: UIEvent) -> String {
    return "\(Self.self) - notify(\(Self.eventDescription(for: event) ?? "\(UIEvent.self)")))"
  }
}
