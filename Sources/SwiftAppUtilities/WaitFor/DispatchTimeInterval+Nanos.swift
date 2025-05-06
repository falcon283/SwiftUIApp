private import Foundation

extension DispatchTimeInterval {

  var nanos: UInt64 {
    switch self {
    case let .seconds(value):
      return NSEC_PER_SEC * UInt64(value)
    case let .milliseconds(value):
      return NSEC_PER_MSEC * UInt64(value)
    case let .microseconds(value):
      return NSEC_PER_USEC * UInt64(value)
    case let .nanoseconds(value):
      return UInt64(value)
    case .never:
      return .max
    default:
      assert(false, "DispatchTimeInterval has been updated. New case to handle: \(self)")
      return NSEC_PER_MSEC
    }
  }
}
