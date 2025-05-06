#if canTestSwiftUI
public import CoreData
internal import SwiftUI
private import SwiftAppUtilities

/// A collection of results retrieved from a Core Data persistent store,
/// grouped into sections.
///
/// Use a `SectionedFetchResults` instance to show or edit Core Data managed
/// objects, grouped into sections, in your app's user interface. If you
/// don't need sectioning, use ``FetchedResults`` instead.
///
/// You request a particular set of results by annotating the fetched results
/// property declaration with a ``SectionedFetchRequest`` property wrapper.
/// Indicate the type of the fetched entities with a `Results` type,
/// and the type of the identifier that distinguishes the sections with
/// a `SectionIdentifier` type. For example, you can create a request to list
/// all `Quake` managed objects that the
/// <doc://com.apple.documentation/documentation/CoreData/loading_and_displaying_a_large_data_feed>
/// sample code project defines to store earthquake data, sorted by their `time`
/// property and grouped by a string that represents the days when earthquakes
/// occurred:
///
///     @SectionedFetchRequest<String, Quake>(
///         sectionIdentifier: \.day,
///         sortDescriptors: [SortDescriptor(\.time, order: .reverse)]
///     )
///     private var quakes: SectionedFetchResults<String, Quake>
///
/// The `quakes` property acts as a collection of ``Section`` instances, each
/// containing a collection of `Quake` instances. The example above depends
/// on the `Quake` model object declaring both `time` and `day`
/// properties, either stored or computed. For best performance with large
/// data sets, use stored properties.
///
/// The collection of sections, as well as the collection of managed objects in
/// each section, conforms to the
/// <doc://com.apple.documentation/documentation/Swift/RandomAccessCollection>
/// protocol, so you can access them as you would any other collection. For
/// example, you can create nested ``ForEach`` loops inside a ``List`` to
/// iterate over the results:
///
///     List {
///         ForEach(quakes) { section in
///             Section(header: Text(section.id)) {
///                 ForEach(section) { quake in
///                     QuakeRow(quake: quake) // Displays information about a quake.
///                 }
///             }
///         }
///     }
///
/// Don't confuse the ``SwiftUI/Section`` view that you use to create a
/// hierarchical display with the ``SectionedFetchResults/Section``
/// instances that hold the fetched results.
///
/// When you need to dynamically change the request's section identifier,
/// predicate, or sort descriptors, set the result instance's
/// ``sectionIdentifier``, ``nsPredicate``, and ``sortDescriptors`` or
/// ``nsSortDescriptors`` properties, respectively. Be sure that the sorting
/// and sectioning work together to avoid discontinguous sections.
///
/// The fetch request and its results use the managed object context stored
/// in the environment, which you can access using the
/// ``EnvironmentValues/managedObjectContext`` environment value. To
/// support user interface activity, you typically rely on the
/// <doc://com.apple.documentation/documentation/CoreData/NSPersistentContainer/1640622-viewContext>
/// property of a shared
/// <doc://com.apple.documentation/documentation/CoreData/NSPersistentContainer>
/// instance. For example, you can set a context on your top-level content
/// view using a container that you define as part of your model:
///
///     ContentView()
///         .environment(
///             \.managedObjectContext,
///             QuakesProvider.shared.container.viewContext)
///
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@MainActor @preconcurrency public struct SectionedFetchResults<SectionIdentifier, Result> : @preconcurrency RandomAccessCollection where SectionIdentifier : Hashable, Result : NSFetchRequestResult {

  private enum FetchType {
    case original(results: SwiftUI.SectionedFetchResults<SectionIdentifier, Result>)
    case test(
      context: NSManagedObjectContext,
      fetchRequest: NSFetchRequest<Result>,
      unSectionedSortDescriptors: ThreadSafe<[NSSortDescriptor]>,
      sectionIdentifier: ThreadSafe<KeyPath<Result, SectionIdentifier>>,
      results: ThreadSafe<[SectionedFetchResults<SectionIdentifier, Result>.Section]>
    )
  }

  private let fetchType: FetchType

  init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<Result>, sectionIdentifier: KeyPath<Result, SectionIdentifier>) {

    let unSectionedSortDescriptors = fetchRequest.sortDescriptors ?? []
    let ascending = fetchRequest.sortDescriptors?.first?.ascending ?? true
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: sectionIdentifier, ascending: ascending)] + unSectionedSortDescriptors
    self.fetchType = .test(
      context: context,
      fetchRequest: fetchRequest,
      unSectionedSortDescriptors: ThreadSafe(unSectionedSortDescriptors),
      sectionIdentifier: ThreadSafe(sectionIdentifier),
      results: ThreadSafe(Self.mapSection(by: sectionIdentifier, fetchRequest: fetchRequest, context: context))
    )
  }

  init(results: SwiftUI.SectionedFetchResults<SectionIdentifier, Result>) {
    self.fetchType = .original(results: results)
  }

  /// A collection of fetched results that share a specified identifier.
  ///
  /// Examine a `Section` instance to find the entities that satisfy a
  /// ``SectionedFetchRequest`` predicate, and that have a particular property
  /// with the value stored in the section's ``id-swift.property-1h7qm``
  /// parameter. You specify which property by setting the fetch request's
  /// `sectionIdentifier` parameter during initialization, or by modifying
  /// the corresponding ``SectionedFetchResults`` instance's
  /// ``SectionedFetchResults/sectionIdentifier`` property.
  ///
  /// Obtain specific sections by treating the fetch results as a collection.
  /// For example, consider the following property declaration
  /// that fetches `Quake` managed objects that the
  /// <doc://com.apple.documentation/documentation/CoreData/loading_and_displaying_a_large_data_feed>
  /// sample code project defines to store earthquake data:
  ///
  ///     @SectionedFetchRequest<String, Quake>(
  ///         sectionIdentifier: \.day,
  ///         sortDescriptors: [SortDescriptor(\.time, order: .reverse)]
  ///     )
  ///     private var quakes: SectionedFetchResults<String, Quake>
  ///
  /// Get the first section using a subscript:
  ///
  ///     let firstSection = quakes[0]
  ///
  /// Alternatively, you can loop over the sections to create a list of
  /// sections.
  ///
  ///     ForEach(quakes) { section in
  ///         Text("Section \(section.id) has \(section.count) elements")
  ///     }
  ///
  /// The sections also act as collections, which means
  /// you can use elements like the
  /// <doc://com.apple.documentation/documentation/Swift/Collection/count-4l4qk>
  /// property in the example above.
  @MainActor @preconcurrency public struct Section : @preconcurrency Identifiable, @preconcurrency RandomAccessCollection {

    private enum SectionType {
      case original(SwiftUI.SectionedFetchResults<SectionIdentifier, Result>.Section)
      case test(objects: [Result])
    }

    private let sectionType: SectionType

    init(id: SectionIdentifier, objects: [Result]) {
      self.id = id
      self.sectionType = .test(objects: objects)
    }

    init(_ original: SwiftUI.SectionedFetchResults<SectionIdentifier, Result>.Section) {
      self.id = original.id
      self.sectionType = .original(original)
    }

    /// The index of the first entity in the section.
    public var startIndex: Int {
      switch self.sectionType {
      case let .original(original):
        return original.startIndex

      case let .test(objects):
        return objects.startIndex
      }
    }

    /// The index that's one greater than that of the last entity in the
    /// section.
    public var endIndex: Int {
      switch self.sectionType {
      case let .original(original):
        return original.endIndex

      case let .test(objects):
        return objects.endIndex
      }
    }

    /// Gets the entity at the specified index within the section.
    public subscript(position: Int) -> Result {
      switch self.sectionType {
      case let .original(original):
        return original[position]

      case let .test(objects):
        return objects[position]
      }
    }

    /// The value that all entities in the section share for a specified
    /// key path.
    ///
    /// Specify the key path that the entities share this value with
    /// by setting the ``SectionedFetchRequest``
    /// instance's `sectionIdentifier` parameter during initialization,
    /// or by modifying the corresponding ``SectionedFetchResults``
    /// instance's ``SectionedFetchResults/sectionIdentifier`` property.
    @MainActor @preconcurrency public let id: SectionIdentifier

    /// A type representing the sequence's elements.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias Element = Result

    /// A type representing the stable identity of the entity associated with
    /// an instance.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias ID = SectionIdentifier

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias Index = Int

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias Indices = Range<Int>

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias Iterator = IndexingIterator<SectionedFetchResults<SectionIdentifier, Result>.Section>

    /// A collection representing a contiguous subrange of this collection's
    /// elements. The subsequence shares indices with the original collection.
    ///
    /// The default subsequence type for collections that don't define their own
    /// is `Slice`.
    @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
    public typealias SubSequence = Slice<SectionedFetchResults<SectionIdentifier, Result>.Section>
  }

  /// The request's sort descriptors, accessed as reference types.
  ///
  /// Set this value to cause the associated ``SectionedFetchRequest`` to
  /// execute a fetch with a new collection of
  /// <doc://com.apple.documentation/documentation/Foundation/NSSortDescriptor>
  /// instances.
  /// The order of managed objects stored in the results collection may change
  /// as a result. Use care to coordinate section and sort updates, as
  /// described in ``SectionedFetchRequest/Configuration``.
  ///
  /// If you want to use
  /// <doc://com.apple.documentation/documentation/Foundation/SortDescriptor>
  /// instances, set ``SectionedFetchResults/sortDescriptors`` instead.
  @MainActor @preconcurrency public var nsSortDescriptors: [NSSortDescriptor] {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.nsSortDescriptors

      case let .test(_, _, unSectionedSortDescriptors, _, _):
        return unSectionedSortDescriptors.wrappedValue
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.nsSortDescriptors = newValue

      case let .test(context, fetchRequest, unSectionedSortDescriptors, sectionIdentifier, results):
        unSectionedSortDescriptors.projectedValue.assign(newValue)
        let ascending = unSectionedSortDescriptors.wrappedValue.first?.ascending ?? true
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: sectionIdentifier.wrappedValue, ascending: ascending)] + newValue
        results.projectedValue.assign(
          Self.mapSection(by: sectionIdentifier.wrappedValue, fetchRequest: fetchRequest, context: context)
        )
      }
    }
  }

  /// The request's predicate.
  ///
  /// Set this value to cause the associated ``SectionedFetchRequest`` to
  /// execute a fetch with a new predicate, producing an updated collection
  /// of results.
  @MainActor @preconcurrency public var nsPredicate: NSPredicate? {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.nsPredicate

      case let .test(_, fetchRequest, _, _, _):
        return fetchRequest.predicate
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.nsPredicate = newValue

      case let .test(context, fetchRequest, _, sectionIdentifier, results):
        fetchRequest.predicate = newValue
        results.projectedValue.assign(
          Self.mapSection(by: sectionIdentifier.wrappedValue, fetchRequest: fetchRequest, context: context)
        )
      }
    }
  }

  /// The key path that the system uses to group fetched results into sections.
  ///
  /// Set this value to cause the associated ``SectionedFetchRequest`` to
  /// execute a fetch with a new section identifier, producing an updated
  /// collection of results. Changing this value produces a new set of
  /// sections. Use care to coordinate section and sort updates, as described
  /// in ``SectionedFetchRequest/Configuration``.
  @MainActor @preconcurrency public var sectionIdentifier: KeyPath<Result, SectionIdentifier> {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.sectionIdentifier

      case let .test(_, _, _, sectionIdentifier, _):
        return sectionIdentifier.wrappedValue
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.sectionIdentifier = newValue

      case let .test(context, fetchRequest, unSectionedSortDescriptors, sectionIdentifier, results):
        sectionIdentifier.projectedValue.assign(newValue)
        let ascending = unSectionedSortDescriptors.wrappedValue.first?.ascending ?? true
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: newValue, ascending: ascending)] + unSectionedSortDescriptors.wrappedValue
        results.projectedValue.assign(
          Self.mapSection(by: sectionIdentifier.wrappedValue, fetchRequest: fetchRequest, context: context)
        )
      }
    }
  }

  /// The index of the first section in the results collection.
  public var startIndex: Int {
    switch self.fetchType {
    case let .original(results):
      return results.startIndex

    case let .test(_, _, _, _, results):
      return results.wrappedValue.startIndex
    }
  }

  /// The index that's one greater than that of the last section.
  public var endIndex: Int {
    switch self.fetchType {
    case let .original(results):
      return results.endIndex

    case let .test(_, _, _, _, results):
      return results.wrappedValue.endIndex
    }
  }

  /// Gets the section at the specified index.
  public subscript(position: Int) -> SectionedFetchResults<SectionIdentifier, Result>.Section {
    switch self.fetchType {
    case let .original(results):
      return Section(results[position])

    case let .test(_, _, _, _, results):
      return results.wrappedValue[position]
    }
  }

  /// A type representing the sequence's elements.
  @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
  public typealias Element = SectionedFetchResults<SectionIdentifier, Result>.Section

  /// A type that represents a position in the collection.
  ///
  /// Valid indices consist of the position of every element and a
  /// "past the end" position that's not valid for use as a subscript
  /// argument.
  @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
  public typealias Index = Int

  /// A type that represents the indices that are valid for subscripting the
  /// collection, in ascending order.
  @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
  public typealias Indices = Range<Int>

  /// A type that provides the collection's iteration interface and
  /// encapsulates its iteration state.
  ///
  /// By default, a collection conforms to the `Sequence` protocol by
  /// supplying `IndexingIterator` as its associated `Iterator`
  /// type.
  @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
  public typealias Iterator = IndexingIterator<SectionedFetchResults<SectionIdentifier, Result>>

  /// A collection representing a contiguous subrange of this collection's
  /// elements. The subsequence shares indices with the original collection.
  ///
  /// The default subsequence type for collections that don't define their own
  /// is `Slice`.
  @available(iOS 15.0, tvOS 15.0, watchOS 8.0, macOS 12.0, *)
  public typealias SubSequence = Slice<SectionedFetchResults<SectionIdentifier, Result>>
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension SectionedFetchResults where Result : NSManagedObject {

  /// The request's sort descriptors, accessed as value types.
  ///
  /// Set this value to cause the associated ``SectionedFetchRequest`` to
  /// execute a fetch with a new collection of
  /// <doc://com.apple.documentation/documentation/Foundation/SortDescriptor>
  /// instances. The order of entities stored in the results collection may
  /// change as a result. Use care to coordinate section and sort updates, as
  /// described in ``SectionedFetchRequest/Configuration``.
  ///
  /// If you want to use
  /// <doc://com.apple.documentation/documentation/Foundation/NSSortDescriptor>
  /// instances, set ``SectionedFetchResults/nsSortDescriptors`` instead.
  @MainActor @preconcurrency public var sortDescriptors: [SortDescriptor<Result>] {
    get {
      switch self.fetchType {
      case let .original(results):
        return results.sortDescriptors

      case let .test(_, _, unSectionedSortDescriptors, _, _):
        return unSectionedSortDescriptors.wrappedValue.compactMap { descriptor in
          let nsDescriptor = NSSortDescriptor(key: descriptor.key, ascending: descriptor.ascending)
          return SortDescriptor(nsDescriptor, comparing: Result.self)
        }
      }
    }
    nonmutating set {
      switch self.fetchType {
      case let .original(results):
        results.sortDescriptors = newValue

      case let .test(context, fetchRequest, unSectionedSortDescriptors, sectionIdentifier, results):
        let newValue = newValue.map { NSSortDescriptor($0) }
        unSectionedSortDescriptors.projectedValue.assign(newValue)
        let ascending = unSectionedSortDescriptors.wrappedValue.first?.ascending ?? true
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: sectionIdentifier.wrappedValue, ascending: ascending)] + newValue
        results.projectedValue.assign(
          Self.mapSection(by: sectionIdentifier.wrappedValue, fetchRequest: fetchRequest, context: context)
        )
      }
    }
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension SectionedFetchResults : Sendable {
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension SectionedFetchResults.Section : Sendable {
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private extension SectionedFetchResults {

  static func mapSection(by sectionIdentifier: KeyPath<Result, SectionIdentifier>, fetchRequest: NSFetchRequest<Result>, context: NSManagedObjectContext) -> [Section] {

    let keyPath = NSFetchRequestExpression(forKeyPath: sectionIdentifier).keyPath
    let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: keyPath, cacheName: nil)
    try? controller.performFetch()

    return controller.sections?.compactMap { section in
      guard let objects = (section.objects ?? []) as? [Result],
            let firstResult = objects.first
      else { return nil }

      return Section(id: firstResult[keyPath: sectionIdentifier], objects: objects)
    } ?? []
  }
}
#endif
