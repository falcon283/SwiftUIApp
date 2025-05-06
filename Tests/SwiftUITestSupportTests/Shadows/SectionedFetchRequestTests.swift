import Testing
import CoreData
import SwiftUI
import SwiftUITestSupport

extension CoreDataTests {

  @MainActor
  struct SectionedFetchRequestTests {

    static let modelName = "TestModel"
  }

}

extension CoreDataTests.SectionedFetchRequestTests {

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
    } expect: { sut in
      #expect(sut.sortedObjectsEntitySection.count == 0)
      #expect(sut.sortedObjectsLegacySection.count == 0)
      #expect(sut.sortedObjectsLegacySection.count == 0)
      #expect(sut.sortedObjectsSection.count == 0)
      #expect(sut.filteredObjectsSection.count == 0)
      #expect(sut.filteredObjectsTransactionSection.count == 0)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_Insert_Then_InsertValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MySectionedObject.self) { $0.value = 20; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 10; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 30; $0.section = "b" }

    } expect: { sut in
      #expect(sut.sortedObjectsEntitySection.count == 2)
      #expect(sut.sortedObjectsEntitySection[0].count == 2)
      #expect(sut.sortedObjectsEntitySection[0][0].value == 10)
      #expect(sut.sortedObjectsEntitySection[0][1].value == 20)
      #expect(sut.sortedObjectsEntitySection[1].count == 1)
      #expect(sut.sortedObjectsEntitySection[1][0].value == 30)

      #expect(sut.sortedObjectsLegacySection.count == 2)
      #expect(sut.sortedObjectsLegacySection[0].count == 2)
      #expect(sut.sortedObjectsLegacySection[0][0].value == 10)
      #expect(sut.sortedObjectsLegacySection[0][1].value == 20)
      #expect(sut.sortedObjectsLegacySection[1].count == 1)
      #expect(sut.sortedObjectsLegacySection[1][0].value == 30)

      #expect(sut.sortedObjectsSection.count == 2)
      #expect(sut.sortedObjectsSection[0].count == 2)
      #expect(sut.sortedObjectsSection[0][0].value == 10)
      #expect(sut.sortedObjectsSection[0][1].value == 20)
      #expect(sut.sortedObjectsSection[1].count == 1)
      #expect(sut.sortedObjectsSection[1][0].value == 30)

      #expect(sut.filteredObjectsSection.count == 1)
      #expect(sut.filteredObjectsSection[0].count == 1)
      #expect(sut.filteredObjectsSection[0][0].value == 20)

      #expect(sut.filteredObjectsTransactionSection.count == 1)
      #expect(sut.filteredObjectsTransactionSection[0].count == 1)
      #expect(sut.filteredObjectsTransactionSection[0][0].value == 20)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_ChangingPredicate_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MySectionedObject.self) { $0.value = 20; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 10; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 30; $0.section = "b" }

    } expect: { sut in

      sut.sortedObjectsSection.nsPredicate = NSPredicate(format: "value == %d", 20)

      #expect(sut.sortedObjectsSection.count == 1)
      #expect(sut.sortedObjectsSection[0].count == 1)
      #expect(sut.sortedObjectsSection[0][0].value == 20)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_ChangingNSSortDescriptor_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MySectionedObject.self) { $0.value = 20; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 10; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 30; $0.section = "b" }

    } expect: { sut in

      sut.sortedObjectsSection.nsSortDescriptors = [NSSortDescriptor(keyPath: \MySectionedObject.value, ascending: false)]

      #expect(sut.sortedObjectsSection.count == 2)
      #expect(sut.sortedObjectsSection[0].count == 1)
      #expect(sut.sortedObjectsSection[0][0].value == 30)
      #expect(sut.sortedObjectsSection[1].count == 2)
      #expect(sut.sortedObjectsSection[1][0].value == 20)
      #expect(sut.sortedObjectsSection[1][1].value == 10)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_ChangingSortDescriptor_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MySectionedObject.self) { $0.value = 20; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 10; $0.section = "a" }
        .insert(MySectionedObject.self) { $0.value = 30; $0.section = "b" }

    } expect: { sut in

      sut.sortedObjectsSection.sortDescriptors = [SortDescriptor(\.value, order: .reverse)]

      #expect(sut.sortedObjectsSection.count == 2)
      #expect(sut.sortedObjectsSection[0].count == 1)
      #expect(sut.sortedObjectsSection[0][0].value == 30)
      #expect(sut.sortedObjectsSection[1].count == 2)
      #expect(sut.sortedObjectsSection[1][0].value == 20)
      #expect(sut.sortedObjectsSection[1][1].value == 10)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_SectionedFetchRequest_When_ChangingSectionIdentifier_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MySectionedObject.self) { $0.value = 20; $0.section = "a"; $0.alternativeSection = "b" }
        .insert(MySectionedObject.self) { $0.value = 10; $0.section = "a"; $0.alternativeSection = "b" }
        .insert(MySectionedObject.self) { $0.value = 30; $0.section = "b"; $0.alternativeSection = "a" }

    } expect: { sut in

      sut.sortedObjectsSection.sectionIdentifier = \.alternativeSection

      #expect(sut.sortedObjectsSection.count == 2)
      #expect(sut.sortedObjectsSection[0].count == 1)
      #expect(sut.sortedObjectsSection[0][0].value == 30)
      #expect(sut.sortedObjectsSection[1].count == 2)
      #expect(sut.sortedObjectsSection[1][0].value == 10)
      #expect(sut.sortedObjectsSection[1][1].value == 20)
    }
  }
}

// MARK: - Test Objects

#if canTestSwiftUI
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private typealias SectionedFetchRequest = SwiftUITestSupport.SectionedFetchRequest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private typealias SectionedFetchResults = SwiftUITestSupport.SectionedFetchResults
#endif

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView: View {

  private static func only20() -> NSFetchRequest<MySectionedObject> {
    let request = NSFetchRequest<MySectionedObject>()
    request.entity = MySectionedObject.entity()
    request.predicate = NSPredicate(format: "value == %d", 20)
    return request
  }

  @SectionedFetchRequest(
    entity: MySectionedObject.entity(),
    sectionIdentifier: \MySectionedObject.section,
    sortDescriptors: [NSSortDescriptor(keyPath: \MySectionedObject.value, ascending: true)]
  )
  var sortedObjectsEntitySection: SectionedFetchResults<String?, MySectionedObject>

  @SectionedFetchRequest(
    sectionIdentifier: \MySectionedObject.section,
    sortDescriptors: [NSSortDescriptor(keyPath: \MySectionedObject.value, ascending: true)]
  )
  var sortedObjectsLegacySection: SectionedFetchResults<String?, MySectionedObject>

  @SectionedFetchRequest(
    sectionIdentifier: \.section,
    sortDescriptors: [SortDescriptor(\.value, order: .forward)]
  )
  var sortedObjectsSection: SectionedFetchResults<String?, MySectionedObject>

  @SectionedFetchRequest(fetchRequest: Self.only20(), sectionIdentifier: \.section)
  var filteredObjectsSection: SectionedFetchResults<String?, MySectionedObject>

  @SectionedFetchRequest(fetchRequest: Self.only20(), sectionIdentifier: \.section, transaction: .init())
  var filteredObjectsTransactionSection: SectionedFetchResults<String?, MySectionedObject>

  var body: some View { EmptyView() }
}
