import Testing
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct TestView: View {

  @AppStorage("AppStorageKey")
  var value: Bool = false

  var body: some View { EmptyView() }
}

// ⚠️ @AppStorage is Testable.
// Anyway we need to Shadow it so to avoid writing on UserDefaults

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  final class SwiftUI_AppStorageTestAbilityChecks {

    init() { self.reset() }

    deinit { self.reset() }

    nonisolated private func reset() {
      UserDefaults().removeObject(forKey: "AppStorageKey")
    }
  }
}


extension SwiftUIBehaviour.SwiftUI_AppStorageTestAbilityChecks {

  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @Test
  func Given_AnAppStorageInAView_When_ValueIsChanged_Then_UpdatedValueCanBeReadBack() async {

    let sut = TestView()

    #expect(sut.value == false)
    sut.value = true
    #expect(sut.value == true, "@AppStorage behavior Changed! It was previously changing from the initial value.")
  }
}
