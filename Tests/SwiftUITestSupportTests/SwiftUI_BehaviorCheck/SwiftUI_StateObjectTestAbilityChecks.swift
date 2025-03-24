import Testing
import Foundation
import SwiftUI

private final class TestObject<T>: ObservableObject {

  @Published
  var value: T

  init(value: T) {
    self.value = value
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @StateObject
  var object = TestObject(value: 10)

  var body: some View { EmptyView() }
}

// ❌ @StateObject is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_StateObjectTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_StateObjectTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AStateObjectInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() {

    let sut = TestView()

    #expect(sut.object.value == 10)

    sut.object.value = 20

    #expect(sut.object.value == 10, "@StateObject behavior Changed! It was previously not changing from the initial value.")
  }
}
