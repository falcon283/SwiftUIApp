import Testing

@testable import SwiftUIApp

private struct TestView<UIEvent>: ViewFeature {

  func notify(_ event: UIEvent) async { }

  func body(with bag: CancellationBag) -> some View { EmptyView() }
}

@MainActor
@Suite
struct ViewFeatureCancellationIdTests {

  @Test
  func Given_StructEvent_Then_EventDescriptionHasTypeAndPropertiesWithNoValues() async throws {

    struct StructEvent {
      var int: Int
      var string: String
      var object: NSObject
    }

    let id = TestView.eventIdentifier(for: StructEvent(int: 0, string: "", object: NSObject()))

    #expect(id == "StructEvent { int: Int; string: String; object: NSObject }" as AnyHashable)
  }

  @Test
  func Given_ClassEvent_Then_EventDescriptionHasPropertiesLabelAndTypeWithNoValue() async throws {

    final class ClassEvent {
      var int: Int
      var string: String
      var object: NSObject

      init(int: Int, string: String, object: NSObject) {
        self.int = int
        self.string = string
        self.object = object
      }
    }

    let id = TestView.eventIdentifier(for: ClassEvent(int: 0, string: "", object: NSObject()))

    #expect(id == "ClassEvent { int: Int; string: String; object: NSObject }" as AnyHashable)
  }

  @Test
  func Given_NamedEnumerationUIEvent_Then_EventDescriptionIsTheCaseName() async throws {

    enum EnumEvent: NamedEvent {
      case foo(int: Int)

      var caseName: String {
        switch self {
        case .foo:
          ".foo(int: Int)"
        }
      }
    }

    #expect(TestView.eventIdentifier(for: EnumEvent.foo(int: 0)) == ".foo(int: Int)" as AnyHashable)
  }

  @Test
  func Given_IdentifiableUIEvent_Then_EventDescriptionIsTheId() async throws {

    enum EnumEvent: Identifiable {
      case foo(int: Int)

      var id: Double {
        switch self {
        case .foo: 111.0
        }
      }
    }

    #expect(TestView.eventIdentifier(for: EnumEvent.foo(int: 0)) == 111.0 as AnyHashable)
  }

  @Test
  func Given_EnumEvent_Then_EventDescriptionHasPropertiesLabelAndTypeWithNoValue() async throws {

    enum EnumEvent {
      case simple
      case associatedOne(int: Int)
      case associatedOneNoName(Int)
      case associatedTwo(int: Int, string: String)
      case associatedTwoNoName(Int, String)
      case associatedTwoMixed(int: Int, String)
      case associatedReference(ref: NSObject)
    }

    #expect(TestView.eventIdentifier(for: EnumEvent.simple) == ".simple" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedOne(int: 0)) == ".associatedOne(int: Int)" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedOneNoName(0)) == ".associatedOneNoName(.0: Int)" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedTwo(int: 0, string: "")) == ".associatedTwo(int: Int, string: String)" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedTwoNoName(0, "")) == ".associatedTwoNoName(.0: Int, .1: String)" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedTwoMixed(int: 0, "")) == ".associatedTwoMixed(int: Int, .1: String)" as AnyHashable)
    #expect(TestView.eventIdentifier(for: EnumEvent.associatedReference(ref: NSObject())) == ".associatedReference(ref: NSObject)" as AnyHashable)
  }

  @Test
  func Given_TupleEvent_Then_EventDescriptionHasPropertiesLabelAndTypeWithNoValue() async throws {

    #expect(TestView<Int>.eventIdentifier(for: 0) == "Int" as AnyHashable)
    #expect(TestView<()>.eventIdentifier(for: ()) == "()" as AnyHashable)
    #expect(TestView<(Int)>.eventIdentifier(for: 0) == "Int" as AnyHashable)
    #expect(TestView<(Int, String)>.eventIdentifier(for: (0, "")) == "(.0: Int, .1: String)" as AnyHashable)
    #expect(TestView<(int: Int, string: String)>.eventIdentifier(for: (0, "")) == "(int: Int, string: String)" as AnyHashable)
  }
}
