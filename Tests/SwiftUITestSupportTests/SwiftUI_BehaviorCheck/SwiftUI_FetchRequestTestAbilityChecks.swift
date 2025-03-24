import Testing
import CoreData
import SwiftUI

@objc(TestObject)
private final class TestObject: NSManagedObject {
  @NSManaged var name: String
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
private struct TestView: View {

  @FetchRequest<TestObject>(sortDescriptors: [SortDescriptor(\.name)])
  var objects

  var body: some View { EmptyView() }
}

// ❌ @FetchRequest is not Testable.
// We can't inject a fake CoreData Stack so to enable testing.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_FetchRequestTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_FetchRequestTestAbilityChecks {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_AFetchRequestInAView_Then_ResultsIsEmpty() async {

    let sut = TestView()

    #expect(sut.objects.count == 0, "@FetchRequest behavior Changed!")
  }
}
