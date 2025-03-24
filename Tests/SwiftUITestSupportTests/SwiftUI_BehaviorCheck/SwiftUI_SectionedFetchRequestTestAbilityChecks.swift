import Testing
import CoreData
import SwiftUI

@objc(TestObject)
private final class TestObject: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var time: String
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor
private struct TestView: View {

  @SectionedFetchRequest(sectionIdentifier: \TestObject.name, sortDescriptors: [SortDescriptor(\.time)])
  var objects

  var body: some View { EmptyView() }
}

// ❌ @SectionedFetchRequest is not Testable.
// We can't inject a fake CoreData Stack so to enable testing.

extension SwiftUIBehaviour {

  @Suite
  @MainActor
  struct SwiftUI_SectionedFetchRequestTestAbilityChecks { }
}

extension SwiftUIBehaviour.SwiftUI_SectionedFetchRequestTestAbilityChecks {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_ASectionedFetchRequestInAView_Then_ResultsIsEmpty() async {

    let sut = TestView()

    #expect(sut.objects.count == 0, "@SectionedFetchRequest behavior Changed!")
  }
}
