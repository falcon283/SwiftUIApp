#if canTestSwiftUI
public import SwiftUI
public import CoreData
private import SwiftAppUtilities

/// A collection of results retrieved from a Core Data store.
///
/// Use a `FetchedResults` instance to show or edit Core Data managed objects in
/// your app's user interface. You request a particular set of results by
/// specifying a `Result` type as the entity type, and annotating the fetched
/// results property declaration with a ``FetchRequest`` property wrapper.
/// For example, you can create a request to list all `Quake` managed objects
/// that the
/// <doc://com.apple.documentation/documentation/CoreData/loading_and_displaying_a_large_data_feed>
/// sample code project defines to store earthquake data, sorted by their
/// `time` property:
///
///     @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)])
///     private var quakes: FetchedResults<Quake>
///
/// The results instance conforms to
/// <doc://com.apple.documentation/documentation/Swift/RandomAccessCollection>,
/// so you access it like any other collection. For example, you can create
/// a ``List`` that iterates over all the results:
///
///     List(quakes) { quake in
///         NavigationLink(destination: QuakeDetail(quake: quake)) {
///             QuakeRow(quake: quake)
///         }
///     }
///
/// When you need to dynamically change the request's predicate or sort
/// descriptors, set the result instance's ``nsPredicate`` and
/// ``sortDescriptors`` or ``nsSortDescriptors`` properties, respectively.
///
/// The fetch request and its results use the managed object context stored
/// in the environment, which you can access using the
/// ``EnvironmentValues/managedObjectContext`` environment value. To
/// support user interface activity, you typically rely on the
/// <doc://com.apple.documentation/documentation/CoreData/NSPersistentContainer/1640622-viewContext>
/// property of a shared
/// <doc://com.apple.documentation/documentation/CoreData/NSPersistentContainer>
/// instance. For example, you can set a context on your top level content
/// view using a container that you define as part of your model:
///
///     ContentView()
///         .environment(
///             \.managedObjectContext,
///             QuakesProvider.shared.container.viewContext)
///
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@MainActor @preconcurrency public struct FetchedResults<Result> : @preconcurrency RandomAccessCollection where Result : NSFetchRequestResult {

  private enum FetchType {
    case original(results: SwiftUI.FetchedResults<Result>)
    case test(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<Result>, results: ThreadSafe<[Result]>)
  }

  private let fetchType: FetchType

  init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<Result>) {
    let results = (try? context.fetch(fetchRequest)) ?? []
    self.fetchType = .test(context: context, fetchRequest: fetchRequest, results: ThreadSafe(results))
  }

  init(results: SwiftUI.FetchedResults<Result>) {
    self.fetchType = .original(results: results)
  }

  /// The request's sort descriptors, accessed as reference types.
  ///
  /// Set this value to cause the associated ``FetchRequest`` to execute
  /// a fetch with a new collection of
  /// <doc://com.apple.documentation/documentation/Foundation/NSSortDescriptor>
  /// instances.
  /// The order of managed objects stored in the results collection may change
  /// as a result.
  ///
  /// If you want to use
  /// <doc://com.apple.documentation/documentation/Foundation/SortDescriptor>
  /// instances, set ``FetchedResults/sortDescriptors`` instead.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @MainActor @preconcurrency public var nsSortDescriptors: [NSSortDescriptor] {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.nsSortDescriptors

      case let .test(_, fetchRequest, _):
        return fetchRequest.sortDescriptors ?? []
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.nsSortDescriptors = newValue

      case let .test(context, fetchRequest, results):
        fetchRequest.sortDescriptors = newValue
        results.projectedValue.assign((try? context.fetch(fetchRequest)) ?? [])
      }
    }
  }

  /// The request's predicate.
  ///
  /// Set this value to cause the associated ``FetchRequest`` to execute a
  /// fetch with a new predicate, producing an updated collection of results.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  @MainActor @preconcurrency public var nsPredicate: NSPredicate? {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.nsPredicate

      case let .test(_, fetchRequest, _):
        return fetchRequest.predicate
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.nsPredicate = newValue

      case let .test(context, fetchRequest, results):
        fetchRequest.predicate = newValue
        results.projectedValue.assign((try? context.fetch(fetchRequest)) ?? [])
      }
    }
  }

  /// The index of the first entity in the results collection.
  public var startIndex: Int {
    switch self.fetchType {
    case let .original(results):
      return results.startIndex

    case let .test(_, _, results):
      return results.wrappedValue.startIndex
    }
  }

  /// The index that's one greater than the last valid subscript argument.
  @MainActor @preconcurrency public var endIndex: Int {
    switch self.fetchType {
    case let .original(results):
      return results.endIndex

    case let .test(_, _, results):
      return results.wrappedValue.endIndex
    }
  }

  /// Gets the entity at the specified index.
  @MainActor @preconcurrency public subscript(position: Int) -> Result {
    switch self.fetchType {
    case let .original(results):
      return results[position]

    case let .test(_, _, results):
      return results.wrappedValue[position]
    }
  }

  /// A type representing the sequence's elements.
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public typealias Element = Result

  /// A type that represents a position in the collection.
  ///
  /// Valid indices consist of the position of every element and a
  /// "past the end" position that's not valid for use as a subscript
  /// argument.
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public typealias Index = Int

  /// A type that represents the indices that are valid for subscripting the
  /// collection, in ascending order.
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public typealias Indices = Range<Int>

  /// A type that provides the collection's iteration interface and
  /// encapsulates its iteration state.
  ///
  /// By default, a collection conforms to the `Sequence` protocol by
  /// supplying `IndexingIterator` as its associated `Iterator`
  /// type.
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public typealias Iterator = IndexingIterator<FetchedResults<Result>>

  /// A collection representing a contiguous subrange of this collection's
  /// elements. The subsequence shares indices with the original collection.
  ///
  /// The default subsequence type for collections that don't define their own
  /// is `Slice`.
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public typealias SubSequence = Slice<FetchedResults<Result>>
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension FetchedResults where Result : NSManagedObject {

  /// The request's sort descriptors, accessed as value types.
  ///
  /// Set this value to cause the associated ``FetchRequest`` to execute a
  /// fetch with a new collection of
  /// <doc://com.apple.documentation/documentation/Foundation/SortDescriptor>
  /// instances.
  /// The order of entities stored in the results collection may change
  /// as a result.
  ///
  /// If you want to use
  /// <doc://com.apple.documentation/documentation/Foundation/NSSortDescriptor>
  /// instances, set ``FetchedResults/nsSortDescriptors`` instead.
  @MainActor @preconcurrency public var sortDescriptors: [SortDescriptor<Result>] {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.sortDescriptors

      case let .test(_, fetchRequest, _):
        return fetchRequest.sortDescriptors?.compactMap { descriptor in
          let nsDescriptor = NSSortDescriptor(key: descriptor.key, ascending: descriptor.ascending)
          return SortDescriptor(nsDescriptor, comparing: Result.self)
        } ?? []
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.sortDescriptors = newValue

      case let .test(context, fetchRequest, results):
        fetchRequest.sortDescriptors = newValue.map { NSSortDescriptor($0) }
        results.projectedValue.assign((try? context.fetch(fetchRequest)) ?? [])
      }
    }
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FetchedResults : Sendable {
}
#endif
