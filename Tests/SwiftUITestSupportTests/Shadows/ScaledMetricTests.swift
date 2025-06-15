import Testing
import SwiftUI
import SwiftUITestSupport

@MainActor
@Suite
struct ScaledMetricTests {

  @Test
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  func Given_ScaledMetric_When_Created_Then_HasGivenValue() async throws {

    try await given(TestView()) { sut in
      #expect(sut.testValue == 20000)
    }
  }
}

// MARK: - Test Objects

#if canTestSwiftUI
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private typealias ScaledMetric = SwiftUITestSupport.ScaledMetric
#endif

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @ScaledMetric
  var testValue = 20000

  var body: some View { EmptyView() }
}
