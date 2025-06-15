#if DEBUG
public import Foundation

/// An helper meant to be used during Unit Test so to wait a particular condition
/// - Parameters:
///   - timeout: A value to use as timeout if the operation takes too much time. `.milliseconds(500)` by default.
///   - polling: The time to wait between a check and the next. `.milliseconds(1)` by default.
///   - isolation: The actor isolation to use when executing.
///   - now: The now time dispatcher
///   - expected: The expectation to verify
/// 
/// - Warning: This function is only available in `DEBUG` builds.
///
/// - Returns: The result of the expectation
public func waiting(
  timeout: DispatchTimeInterval = .milliseconds(500),
  interval polling: DispatchTimeInterval = .milliseconds(1),
  isolation: isolated (any Actor)? = #isolation,
  now: @Sendable () -> DispatchTime = DispatchTime.now,
  _ expected: @autoclosure () -> Bool
) async -> Bool {
  let beginTime = now()

  while beginTime.distance(to: now()).nanos < timeout.nanos {
    try? await Task.sleep(nanoseconds: polling.nanos)
    if Task.isCancelled { return expected() }
    await Task.yield()
    if expected() { return true }
  }
  return false
}
#endif
