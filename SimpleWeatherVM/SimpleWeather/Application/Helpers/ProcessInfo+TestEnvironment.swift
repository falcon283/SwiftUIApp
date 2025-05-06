import Foundation

extension ProcessInfo {

  static var isRunningUnitTests: Bool {
    ProcessInfo.processInfo.environment["isRunningUnitTests"] == "true"
  }
}
