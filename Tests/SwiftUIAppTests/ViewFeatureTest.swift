import Testing
import SwiftAppUtilities
import SwiftUITestSupport
@testable import SwiftUIApp

@Suite
@MainActor
struct Given_ViewFeature {

  private struct TestViewFeature: ViewFeature, View {

    enum UIEvent {
      case updateValue
      case text(String)
      case waiting(milliseconds: UInt64)
    }

    @State
    private(set) var value = 10

    @State
    private(set) var text = "Test"

    nonmutating func notify(_ event: UIEvent) async {
      switch event {
      case .updateValue:
        self.value = 20

      case let .text(text):
        self.text = text

      case let .waiting(milliseconds):
        try? await Task.sleep(nanoseconds: NSEC_PER_MSEC * milliseconds)
        guard !Task.isCancelled else { return }
        self.value += 1
      }
    }

    func body(with bag: CancellationBag) -> some View { EmptyView() }
  }
}

extension Given_ViewFeature {

  @Test
  func When_NotifyEventIsSent_Then_BusinessLogicIsExecuted() async throws {

    try await given(TestViewFeature()) { sut in
      #expect(sut.value == 10)
      await sut.notify(.updateValue)
      #expect(sut.value == 20)
    }
  }

  @Test
  func When_BindValueIsSet_Then_BusinessLogicIsExecuted() async throws {

    try await given(TestViewFeature()) { sut, bag in
      #expect(sut.text == "Test")

      let binding = sut.bind(\.text, storeIn: bag, onChangeNotify: .updateValue)
      binding.wrappedValue = "Changed"

      // The binding triggers the send which is asynchronous
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      
      #expect(sut.value == 20)
    }
  }

  @Test
  func When_BindFunctionValueIsSet_Then_BusinessLogicIsExecuted() async throws {

    try await given(TestViewFeature()) { sut, bag in
      #expect(sut.text == "Test")

      let binding = sut.bind(\.text, storeIn: bag, onChangeNotify: TestViewFeature.UIEvent.text)
      binding.wrappedValue = "Changed"

      // The binding triggers the send which is asynchronous
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)

      #expect(sut.text == "Changed")
    }
  }

  @Test
  func When_SynchronousNotifyIsUsed_Then_BusinessLogicIsExecuted() async throws {

    try await given(TestViewFeature()) { sut, bag in

      #expect(sut.value == 10)

      let id = UUID()
      sut.notify(.waiting(milliseconds: 1), storeIn: bag, withId: id)

      #expect(await waiting(sut.value == 11))
    }
  }

  @Test
  func When_SynchronousNotifyIsUsedRepeatedTimesWithSameId_Then_PreviousTasksAreCanceledAndBusinessLogicIsExecutedOnce() async throws {

    try await given(TestViewFeature()) { sut, bag in

      #expect(sut.value == 10)

      let id = UUID()
      sut.notify(.waiting(milliseconds: 5), storeIn: bag, withId: id)
      sut.notify(.waiting(milliseconds: 10), storeIn: bag, withId: id)
      sut.notify(.waiting(milliseconds: 15), storeIn: bag, withId: id)
      sut.notify(.waiting(milliseconds: 20), storeIn: bag, withId: id)

      #expect(await waiting(sut.value == 11))
    }
  }

  @Test
  func When_CancellationBagGetsDestroyed_Then_RunningTaskGetsCanceled() async throws {

    try await given(TestViewFeature()) { sut in

      var bag: CancellationBag! = CancellationBag()

      #expect(sut.value == 10)

      let id = UUID()
      sut.notify(.waiting(milliseconds: 1), storeIn: bag, withId: id)
      bag = nil

      #expect(await waiting(sut.value == 10))
    }
  }
}
