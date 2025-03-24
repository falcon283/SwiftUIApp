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

    var body: some View {
      EmptyView()
    }
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

    try await given(TestViewFeature()) { sut in
      #expect(sut.text == "Test")

      let binding = sut.bind(\.text, onChangeNotify: .updateValue)
      binding.wrappedValue = "Changed"

      // The binding triggers the send which is asynchronous
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)
      
      #expect(sut.value == 20)
    }
  }

  @Test
  func When_BindFunctionValueIsSet_Then_BusinessLogicIsExecuted() async throws {

    try await given(TestViewFeature()) { sut in
      #expect(sut.text == "Test")

      let binding = sut.bind(\.text, onChangeNotify: TestViewFeature.UIEvent.text)
      binding.wrappedValue = "Changed"

      // The binding triggers the send which is asynchronous
      try await Task.sleep(nanoseconds: NSEC_PER_MSEC * 10)

      #expect(sut.text == "Changed")
    }
  }
}
