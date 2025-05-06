import Testing
import CoreData
import SwiftUI
import SwiftUITestSupport

@Suite(.serialized)
struct CoreDataTests { }

extension CoreDataTests {

  @MainActor
  struct FetchRequestTests {

    static let modelName = "TestModel"
  }
}

extension CoreDataTests.FetchRequestTests {

  @Test
  func Given_FetchRequest_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
    } expect: { sut in
      #expect(sut.sortedObjectsEntity.count == 0)
      #expect(sut.sortedObjects.count == 0)
      #expect(sut.filteredObjects.count == 0)
      #expect(sut.filteredObjectsTransaction.count == 0)
    }
  }

  @Test
  func Given_FetchRequest_When_Insert_Then_InsertValueCanBeRead() async throws {

    try await given(TestView()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MyObject.self) { $0.value = 30 }
        .insert(MyObject.self) { $0.value = 20 }
        .insert(MyObject.self) { $0.value = 10 }

    } expect: { sut in
      #expect(sut.sortedObjectsEntity.count == 3)
      #expect(sut.sortedObjectsEntity[0].value == 10)
      #expect(sut.sortedObjectsEntity[1].value == 20)
      #expect(sut.sortedObjectsEntity[2].value == 30)

      #expect(sut.sortedObjects.count == 3)
      #expect(sut.sortedObjects[0].value == 10)
      #expect(sut.sortedObjects[1].value == 20)
      #expect(sut.sortedObjects[2].value == 30)

      #expect(sut.filteredObjects.count == 1)
      #expect(sut.filteredObjects[0].value == 20)

      #expect(sut.filteredObjectsTransaction.count == 1)
      #expect(sut.filteredObjectsTransaction[0].value == 20)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FetchRequest15_When_Created_Then_HasDefaultValue() async throws {

    try await given(TestView15()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
    } expect: { sut in
      #expect(sut.sortedObject.count == 0)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FetchRequest15_When_Insert_Then_InsertValueCanBeRead() async throws {

    try await given(TestView15()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MyObject.self) { $0.value = 10 }
        .insert(MyObject.self) { $0.value = 20 }
        .insert(MyObject.self) { $0.value = 30 }

    } expect: { sut in
      #expect(sut.sortedObject.count == 3)
      #expect(sut.sortedObject[0].value == 10)
      #expect(sut.sortedObject[1].value == 20)
      #expect(sut.sortedObject[2].value == 30)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FetchRequest15_When_ChangingPredicate_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView15()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MyObject.self) { $0.value = 10 }
        .insert(MyObject.self) { $0.value = 20 }
        .insert(MyObject.self) { $0.value = 30 }

    } expect: { sut in
      sut.sortedObject.nsPredicate = NSPredicate(format: "value == %d", 20)

      #expect(sut.sortedObject.count == 1)
      #expect(sut.sortedObject[0].value == 20)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FetchRequest15_When_ChangingNSSortDescriptor_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView15()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MyObject.self) { $0.value = 10 }
        .insert(MyObject.self) { $0.value = 20 }
        .insert(MyObject.self) { $0.value = 30 }

    } expect: { sut in
      sut.sortedObject.nsSortDescriptors = [NSSortDescriptor(keyPath: \MyObject.value, ascending: false)]

      #expect(sut.sortedObject.count == 3)
      #expect(sut.sortedObject[0].value == 30)
      #expect(sut.sortedObject[1].value == 20)
      #expect(sut.sortedObject[2].value == 10)
    }
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @Test
  func Given_FetchRequest15_When_ChangingSortDescriptor_Then_UpdatedValueCanBeRead() async throws {

    try await given(TestView15()) {
      try await $0.startCoreData(named: Self.modelName, bundle: .coreDataTestBundle)
        .insert(MyObject.self) { $0.value = 10 }
        .insert(MyObject.self) { $0.value = 20 }
        .insert(MyObject.self) { $0.value = 30 }

    } expect: { sut in
      sut.sortedObject.sortDescriptors = [SortDescriptor(\.value, order: .reverse)]

      #expect(sut.sortedObject.count == 3)
      #expect(sut.sortedObject[0].value == 30)
      #expect(sut.sortedObject[1].value == 20)
      #expect(sut.sortedObject[2].value == 10)
    }
  }
}

// MARK: - Test Objects

#if canTestSwiftUI
private typealias FetchRequest = SwiftUITestSupport.FetchRequest
private typealias FetchedResults = SwiftUITestSupport.FetchedResults
#endif

private struct TestView: View {

  private static func only20() -> NSFetchRequest<MyObject> {
    let request = NSFetchRequest<MyObject>()
    request.entity = MyObject.entity()
    request.predicate = NSPredicate(format: "value == %d", 20)
    return request
  }

  @FetchRequest(entity: MyObject.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \MyObject.value, ascending: true)])
  var sortedObjectsEntity: FetchedResults<MyObject>

  @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \MyObject.value, ascending: true)])
  var sortedObjects: FetchedResults<MyObject>

  @FetchRequest(fetchRequest: Self.only20())
  var filteredObjects: FetchedResults<MyObject>

  @FetchRequest(fetchRequest: Self.only20(), transaction: .init())
  var filteredObjectsTransaction: FetchedResults<MyObject>

  var body: some View { EmptyView() }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestView15: View {

  @FetchRequest(sortDescriptors: [SortDescriptor(\.value, order: .forward)])
  var sortedObject: FetchedResults<MyObject>

  var body: some View { EmptyView() }
}
