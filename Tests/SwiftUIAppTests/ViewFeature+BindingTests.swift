import Testing
import SwiftUITestSupport
import SwiftAppUtilities
@testable import SwiftUIApp

@MainActor
@Suite
struct ViewFeatureBindingTest {

  @Test
  func Given_DerivedBinding_When_UpdatingTheBinding_Then_NotifyIsCalledAndStateIsChanged() async throws {

    try await given(TestFeature()) { sut, bag in
      let notifyBinding = sut.bind(\.paused, storeIn: bag, onChangeNotify: .pause)

      #expect(!sut.paused)

      notifyBinding.wrappedValue = true

      #expect(await waiting(sut.paused))
    }
  }

  @Test
  func Given_DerivedBindingWithClosure_When_UpdatingTheBinding_Then_NotifyIsCalledAndStateIsChanged() async throws {

    try await given(TestFeature()) { sut, bag in
      let notifyBinding = sut.bind(\.paused, storeIn: bag) { _ in .pause }

      #expect(!sut.paused)

      notifyBinding.wrappedValue = true

      #expect(await waiting(sut.paused))
    }
  }
}

private struct TestFeature: ViewFeature {

  enum UIEvent {
    case pause
  }

  @ThreadSafe
  var paused = false

  func notify(_ event: UIEvent) async {
    self.$paused.assign(true)
  }

  func body(with bag: CancellationBag) -> some View { EmptyView() }
}
