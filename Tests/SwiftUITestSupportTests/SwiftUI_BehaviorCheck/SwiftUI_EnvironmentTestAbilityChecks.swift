import Testing
import SwiftUI

private extension EnvironmentValues {
  @Entry var swiftUIEnvironment = 10
}

private struct TestView: View {

  @Environment(\.swiftUIEnvironment)
  var value

  var body: some View { EmptyView() }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
@Observable
private final class TestObservable {

  var value = 10
}

// ❌ @Environment is not Testable.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct Given_SwiftUIEnvironment { }
}
extension SwiftUIBehaviour.Given_SwiftUIEnvironment {

  @Test
  func When_KeyPathReadingDefaultValue_Then_ItCanBeRead() async {

    @Environment(\.swiftUIEnvironment)
    var sut

    #expect(sut == 10)
  }

  @Test
  func When_KeyPathReadingFromView_Then_ItCanBeRead() async {

    let view = TestView()

    #expect(view.value == 10)
  }


  func When_KeyPathChangingValueInView_Then_ItsNotBuilding() async {

    let view = TestView()
      .environment(\.swiftUIEnvironment, 20)

    withExtendedLifetime(view) {}

    // This is kept commented on purpose to showcase we can't inject and test the view anymore.
    // Value of type 'some View' has no member 'value'
    // #expect(view.value == 20)
  }

  @available(iOS 17.0, *)
  func When_ObservableIsUsed_Then_ItsNotTestable() async {

    struct TestViewWithObservable: View {

      @Environment
      var value: TestObservable

      var body: some View { EmptyView() }
    }

    let view = TestView()
      .environment(TestObservable())

    withExtendedLifetime(view) {}

    // This is kept commented on purpose to showcase we can't inject and test the view anymore.
    // Value of type 'some View' has no member 'value'
    // #expect(view.value == 20)
  }

  @available(iOS 17.0, *)
  func When_OptionalObservableIsUsed_Then_ItsNotTestable() async {

    struct TestViewWithObservable: View {

      @Environment
      var value: TestObservable?

      var body: some View { EmptyView() }
    }

    let view = TestView()
      .environment(TestObservable())

    withExtendedLifetime(view) {}

    // This is kept commented on purpose to showcase we can't inject and test the view anymore.
    // Value of type 'some View' has no member 'value'
    // #expect(view.value == 20)
  }
}
