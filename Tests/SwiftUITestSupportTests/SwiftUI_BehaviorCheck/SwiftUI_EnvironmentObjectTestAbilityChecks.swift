import Testing
import SwiftUI

private struct TestView: View {

  @EnvironmentObject
  var value: TestObservableObject

  var body: some View { EmptyView() }
}

private final class TestObservableObject: ObservableObject {

  @Published
  var value = 10
}

// ❌ @EnvironmentObject is not Testable.
// It's required to inject values without `.environmentObject(...)` modifier because using it we will lose the View to run tests on.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct Given_SwiftUIEnvironmentObject { }
}

extension SwiftUIBehaviour.Given_SwiftUIEnvironmentObject {

  // This is kept commented on purpose to showcase @EnvironmentObject is not testable
  //  @Test
  //  func When_ObservableObjectIsUsedInView_Then_ItDoesCrash() async {
  //
  //    let sut = TestView()
  //
  //    withExtendedLifetime(sut.value) {}
  //  }

  func When_ObservableObjectIsUsedInView_Then_ItsNotBuilding() async {

    let sut = TestView()
      .environmentObject(TestObservableObject())

    withExtendedLifetime(sut) { }

    // This is kept commented on purpose to showcase we can't inject and test the view anymore.
    // Value of type 'some View' has no member 'value'
    // #expect(sut.value == 10)
  }
}
