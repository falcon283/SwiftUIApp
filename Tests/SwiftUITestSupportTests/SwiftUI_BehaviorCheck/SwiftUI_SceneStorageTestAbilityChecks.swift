import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @SceneStorage("SceneStorageKey")
  var value: Bool = false

  var body: some View { EmptyView() }
}

// ❌ @SceneStorage is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  final class SwiftUI_SceneStorageTestAbilityChecks {

    init() { self.reset() }

    deinit { self.reset() }

    nonisolated private func reset() {
      UserDefaults().removeObject(forKey: "SceneStorageKey")
    }
  }
}

extension SwiftUIBehaviour.SwiftUI_SceneStorageTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_ASceneStorageInAView_When_ValueIsChanged_Then_UpdatedValueCannotBeReadBack() async {

    let sut = TestView()

    #expect(sut.value == false)
    sut.value = true
    #expect(sut.value == false, "@SceneStorage behavior Changed! It was previously not changing from the initial value.")
  }
}
