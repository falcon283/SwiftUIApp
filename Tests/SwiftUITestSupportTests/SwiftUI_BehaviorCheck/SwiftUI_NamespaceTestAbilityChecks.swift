import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @Namespace
  var value1

  @Namespace
  var value2

  var body: some View { EmptyView() }
}

// ✅ @Namespace is Testable.
// Values cannot be changed by business logic, only from UI Gestures, thus no needs to be replaced

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_NamespaceTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_NamespaceTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_ANamespaceInAView_When_ValuesAreCompared_Then_ValueIsDistinct() async {

    let sut = TestView()

    #expect(sut.value1 != sut.value2, "@Namespace behavior Changed! It was previously changing from the initial value.")
  }
}
