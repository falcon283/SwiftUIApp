#if DEBUG
public import Foundation

/// An helper meant to be used during Unit Test so to wait a particular condition
/// - Parameters:
///   - polling: The time to wait between a check and the next. `.milliseconds(10)` by default.
///   - timeout: A value to use as timeout if the operation takes too much time. `.milliseconds(500)` by default.
///   - isolation: The actor isolation to use when executing.
///   - now: The now time dispatcher
///   - expected: The expectation to verify
///
/// - Warning: This function is only available in `DEBUG` builds.
public func wait(
  for polling: DispatchTimeInterval = .milliseconds(10),
  timeout: DispatchTimeInterval = .milliseconds(500),
  isolation: isolated (any Actor)? = #isolation,
  now: () -> DispatchTime = DispatchTime.now,
  expecting expected: @autoclosure () -> Bool
) async {
  let beginTime = now()

  while beginTime.distance(to: now()).nanos < timeout.nanos && !expected() {
    try? await Task.sleep(nanoseconds: polling.nanos)
    await Task.yield()
  }
}
#endif
