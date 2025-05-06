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

    let description = TestView.eventDescription(for: StructEvent(int: 0, string: "", object: NSObject()))
    let id = TestView.cancellationId(for: StructEvent(int: 0, string: "", object: NSObject()))

    #expect(description == "StructEvent { int: Int; string: String; object: NSObject }")
    #expect(id.description == description)
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

    let description = TestView.eventDescription(for: ClassEvent(int: 0, string: "", object: NSObject()))
    let id = TestView.cancellationId(for: ClassEvent(int: 0, string: "", object: NSObject()))

    #expect(description == "ClassEvent { int: Int; string: String; object: NSObject }")
    #expect(id.description == description)
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

    #expect(TestView.eventDescription(for: EnumEvent.simple) == ".simple")
    #expect(
      TestView.cancellationId(for: EnumEvent.simple).description ==
      TestView.eventDescription(for: EnumEvent.simple)
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedOne(int: 0)) == ".associatedOne(int: Int)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedOne(int: 0)).description ==
      TestView.eventDescription(for: EnumEvent.associatedOne(int: 0))
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedOneNoName(0)) == ".associatedOneNoName(.0: Int)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedOneNoName(0)).description ==
      TestView.eventDescription(for: EnumEvent.associatedOneNoName(0))
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedTwo(int: 0, string: "")) == ".associatedTwo(int: Int, string: String)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedTwo(int: 0, string: "")).description ==
      TestView.eventDescription(for: EnumEvent.associatedTwo(int: 0, string: ""))
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedTwoNoName(0, "")) == ".associatedTwoNoName(.0: Int, .1: String)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedTwoNoName(0, "")).description ==
      TestView.eventDescription(for: EnumEvent.associatedTwoNoName(0, ""))
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedTwoMixed(int: 0, "")) == ".associatedTwoMixed(int: Int, .1: String)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedTwoMixed(int: 0, "")).description ==
      TestView.eventDescription(for: EnumEvent.associatedTwoMixed(int: 0, ""))
    )

    #expect(TestView.eventDescription(for: EnumEvent.associatedReference(ref: NSObject())) == ".associatedReference(ref: NSObject)")
    #expect(
      TestView.cancellationId(for: EnumEvent.associatedReference(ref: NSObject())).description ==
      TestView.eventDescription(for: EnumEvent.associatedReference(ref: NSObject()))
    )
  }

  @Test
  func Given_TupleEvent_Then_EventDescriptionHasPropertiesLabelAndTypeWithNoValue() async throws {

    #expect(TestView<Int>.eventDescription(for: 0) == "Int")
    #expect(TestView<Int>.cancellationId(for: 0).description == TestView<Int>.eventDescription(for: 0))

    #expect(TestView<()>.eventDescription(for: ()) == "()")
    #expect(TestView<()>.cancellationId(for: ()).description == TestView<()>.eventDescription(for: ()))

    #expect(TestView<(Int)>.eventDescription(for: 0) == "Int")
    #expect(TestView<(Int)>.cancellationId(for: 0).description == TestView<(Int)>.eventDescription(for: 0))

    #expect(TestView<(Int, String)>.eventDescription(for: (0, "")) == "(.0: Int, .1: String)")
    #expect(
      TestView<(Int, String)>.cancellationId(for: (0, "")).description ==
      TestView<(Int, String)>.eventDescription(for: (0, ""))
    )

    #expect(TestView<(int: Int, string: String)>.eventDescription(for: (0, "")) == "(int: Int, string: String)")
    #expect(
      TestView<(int: Int, string: String)>.cancellationId(for: (0, "")).description ==
      TestView<(int: Int, string: String)>.eventDescription(for: (0, ""))
    )
  }
}
