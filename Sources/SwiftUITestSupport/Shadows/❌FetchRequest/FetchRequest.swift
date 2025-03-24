public import CoreData
public import SwiftUI
private import SwiftAppUtilities

/// A property wrapper type that retrieves entities from a Core Data persistent
/// store.
///
/// Use a `FetchRequest` property wrapper to declare a `FetchedResults`
/// property that provides a collection of Core Data managed objects to a
/// SwiftUI view. The request infers the entity type from the `Result`
/// placeholder type that you specify. Condition the request with an optional
/// predicate and sort descriptors. For example, you can create a request to
/// list all `Quake` managed objects that the
/// <https://developer.apple.com/documentation/CoreData/loading_and_displaying_a_large_data_feed>
/// sample code project defines to store earthquake data, sorted by their
/// `time` property:
///
/// ```swift
///     @FetchRequest(sortDescriptors: [SortDescriptor(\.time, order: .reverse)])
///     private var quakes: FetchedResults<Quake> // Define Quake in your model.
/// ```
///
/// Alternatively, when you need more flexibility, you can initialize the
/// request with a configured
/// <https://developer.apple.com/documentation/CoreData/NSFetchRequest>
/// instance:
///
/// ```swift
///     @FetchRequest(fetchRequest: request)
///     private var quakes: FetchedResults<Quake>
/// ```
///
/// Always declare properties that have a fetch request wrapper as private.
/// This lets the compiler help you avoid accidentally setting
/// the property from the memberwise initializer of the enclosing view.
///
/// The fetch request and its results use the managed object context stored
/// in the environment, which you can access using the
/// `EnvironmentValues/managedObjectContext` environment value. To
/// support user interface activity, you typically rely on the
/// <https://developer.apple.com/documentation/CoreData/NSPersistentContainer/1640622-viewContext>
/// property of a shared
/// <https://developer.apple.com/documentation/CoreData/NSPersistentContainer>
/// instance. For example, you can set a context on your top level content
/// view using a shared container that you define as part of your model:
///
/// ```swift
///     ContentView()
///         .environment(
///             \.managedObjectContext,
///             QuakesProvider.shared.container.viewContext)
/// ```
///
/// When you need to dynamically change the predicate or sort descriptors,
/// access the request's `FetchRequest/Configuration` structure.
/// To create a request that groups the fetched results according to a
/// characteristic that they share, use ``SectionedFetchRequest`` instead.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@MainActor @propertyWrapper @preconcurrency public struct FetchRequest<Result> where Result : NSFetchRequestResult {

  private var storage: SwiftUI.FetchRequest<Result>

  @ThreadSafe
  private var results: FetchedResults<Result>?
  private let buildFetchRequest: () -> NSFetchRequest<Result>

  /// The fetched results of the fetch request.
  ///
  /// SwiftUI returns the value associated with this property
  /// when you use ``FetchRequest`` as a property wrapper, and then access
  /// the wrapped property by name. For example, consider the following
  /// `quakes` property declaration that fetches a `Quake` type that the
  /// <https://developer.apple.com/documentation/CoreData/loading_and_displaying_a_large_data_feed>
  /// sample code project defines:
  ///
  /// ```swift
  ///     @FetchRequest(fetchRequest: request)
  ///     private var quakes: FetchedResults<Quake>
  /// ```
  ///
  /// You access the request's `wrappedValue`, which contains a
  /// `FetchedResults` instance, by referring to the `quakes` property
  /// by name:
  ///
  /// ```swift
  ///     Text("Found \(quakes.count) earthquakes")
  /// ```
  ///
  /// If you need to separate the request and the result
  /// entities, you can declare `quakes` in two steps by
  /// using the request's `wrappedValue` to obtain the results:
  ///
  /// ```swift
  ///     var fetchRequest = FetchRequest<Quake>(fetchRequest: request)
  ///     var quakes: FetchedResults<Quake> { fetchRequest.wrappedValue }
  /// ```
  ///
  /// The `wrappedValue` property returns an empty array when there are no
  /// fetched results --- for example, because no entities satisfy the
  /// predicate, or because the data store is empty.
  @MainActor @preconcurrency public var wrappedValue: FetchedResults<Result> {
    self._results.wrappedValue ?? self.buildFetchedResults()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FetchRequest : @preconcurrency DynamicProperty {

  /// Updates the fetched results.
  ///
  /// SwiftUI calls this function before rendering a view's
  /// `View/body-swift.property` to ensure the view has the most recent
  /// fetched results.
  @MainActor public mutating func update() {
    self.results = FetchedResults(results: self.storage.wrappedValue)
    self.storage.update()
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FetchRequest {

  /// Creates a fetch request for a specified entity description, based on a
  /// predicate and sort parameters.
  ///
  /// Use this initializer if you need to explicitly specify the entity type
  /// for the request. If you specify a placeholder `Result` type in the
  /// request declaration, use the
  /// ``init(sortDescriptors:predicate:animation:)`` initializer to
  /// let the request infer the entity type. If you need more control over
  /// the fetch request configuration, use ``init(fetchRequest:animation:)``.
  ///
  /// - Parameters:
  ///   - entity: The description of the Core Data entity to fetch.
  ///   - sortDescriptors: An array of sort descriptors that define the sort
  ///     order of the fetched results.
  ///   - predicate: An
  ///     <https://developer.apple.com/documentation/Foundation/NSPredicate>
  ///     instance that defines logical conditions used to filter the fetched
  ///     results.
  ///   - animation: The animation to use for user interface changes that
  ///     result from changes to the fetched results.
  @MainActor @preconcurrency public init(entity: NSEntityDescription, sortDescriptors: [NSSortDescriptor], predicate: NSPredicate? = nil, animation: Animation? = nil) {

    self.buildFetchRequest = {
      let fetchRequest = NSFetchRequest<Result>()
      fetchRequest.entity = entity
      fetchRequest.sortDescriptors = sortDescriptors
      fetchRequest.predicate = predicate
      return fetchRequest
    }
    self.storage = SwiftUI.FetchRequest(entity: entity, sortDescriptors: sortDescriptors, predicate: predicate, animation: animation)
  }

  /// Creates a fully configured fetch request that uses the specified
  /// animation when updating results.
  ///
  /// Use this initializer when you want to configure a fetch
  /// request with more than a predicate and sort descriptors.
  /// For example, you can vend a request from a `Quake` managed object
  /// that the
  /// <https://developer.apple.com/documentation/CoreData/loading_and_displaying_a_large_data_feed>
  /// sample code project defines to store earthquake data.
  /// Limit the number of results to `1000` by setting a
  /// <https://developer.apple.com/documentation/CoreData/NSFetchRequest/1506622-fetchLimit>
  /// for the request:
  ///
  /// ```swift
  ///     extension Quake {
  ///         var request: NSFetchRequest<Quake> {
  ///             let request = NSFetchRequest<Quake>(entityName: "Quake")
  ///             request.sortDescriptors = [
  ///                 NSSortDescriptor(
  ///                     keyPath: \Quake.time,
  ///                     ascending: true)]
  ///             request.fetchLimit = 1000
  ///             return request
  ///         }
  ///     }
  /// ```
  ///
  /// Use the request to define a `FetchedResults` property:
  ///
  /// ```swift
  ///     @FetchRequest(fetchRequest: Quake.request)
  ///     private var quakes: FetchedResults<Quake>
  /// ```
  ///
  /// If you only need to configure the request's predicate and sort
  /// descriptors, use ``init(sortDescriptors:predicate:animation:)``
  /// instead. If you need to specify a `Transaction` rather than an
  /// optional `Animation`, use ``init(fetchRequest:transaction:)``.
  ///
  /// - Parameters:
  ///   - fetchRequest: An
  ///     <https://developer.apple.com/documentation/CoreData/NSFetchRequest>
  ///     instance that describes the search criteria for retrieving data
  ///     from the persistent store.
  ///   - animation: The animation to use for user interface changes that
  ///     result from changes to the fetched results.
  @MainActor @preconcurrency public init(fetchRequest: NSFetchRequest<Result>, animation: Animation? = nil) {
    self.buildFetchRequest = { fetchRequest }
    self.storage = SwiftUI.FetchRequest(fetchRequest: fetchRequest, animation: animation)
  }

  /// Creates a fully configured fetch request that uses the specified
  /// transaction when updating results.
  ///
  /// Use this initializer if you need a fetch request with updates that
  /// affect the user interface based on a `Transaction`. Otherwise, use
  /// ``init(fetchRequest:animation:)``.
  ///
  /// - Parameters:
  ///   - fetchRequest: An
  ///     <https://developer.apple.com/documentation/CoreData/NSFetchRequest>
  ///     instance that describes the search criteria for retrieving data
  ///     from the persistent store.
  ///   - transaction: A transaction to use for user interface changes that
  ///     result from changes to the fetched results.
  @MainActor @preconcurrency public init(fetchRequest: NSFetchRequest<Result>, transaction: Transaction) {
    self.buildFetchRequest = { fetchRequest }
    self.storage = SwiftUI.FetchRequest(fetchRequest: fetchRequest, transaction: transaction)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FetchRequest where Result : NSManagedObject {

  /// Creates a fetch request based on a predicate and reference type sort
  /// parameters.
  ///
  /// The request gets the entity type from the `Result` instance by calling
  /// that managed object's
  /// <https://developer.apple.com/documentation/CoreData/NSManagedObject/1640588-entity>
  /// type method. If you need to specify the entity type explicitly, use the
  /// ``init(entity:sortDescriptors:predicate:animation:)`` initializer
  /// instead. If you need more control over the fetch request configuration,
  /// use ``init(fetchRequest:animation:)``.
  ///
  /// - Parameters:
  ///   - sortDescriptors: An array of sort descriptors that define the sort
  ///     order of the fetched results.
  ///   - predicate: An
  ///     <https://developer.apple.com/documentation/Foundation/NSPredicate>
  ///     instance that defines logical conditions used to filter the fetched
  ///     results.
  ///   - animation: The animation to use for user interface changes that
  ///     result from changes to the fetched results.
  @MainActor @preconcurrency public init(sortDescriptors: [NSSortDescriptor], predicate: NSPredicate? = nil, animation: Animation? = nil) {

    self.buildFetchRequest = {
      let fetchRequest = NSFetchRequest<Result>()
      fetchRequest.entity = Result.entity()
      fetchRequest.sortDescriptors = sortDescriptors
      fetchRequest.predicate = predicate
      return fetchRequest
    }
    self.storage = SwiftUI.FetchRequest(sortDescriptors: sortDescriptors, predicate: predicate, animation: animation)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension FetchRequest where Result : NSManagedObject {

  /// Creates a fetch request based on a predicate and value type sort
  /// parameters.
  ///
  /// The request gets the entity type from the `Result` instance by calling
  /// that managed object's
  /// <https://developer.apple.com/documentation/CoreData/NSManagedObject/1640588-entity>
  /// type method. If you need to specify the entity type explicitly, use the
  /// ``init(entity:sortDescriptors:predicate:animation:)`` initializer
  /// instead. If you need more control over the fetch request configuration,
  /// use ``init(fetchRequest:animation:)``.
  ///
  /// - Parameters:
  ///   - sortDescriptors: An array of sort descriptors that define the sort
  ///     order of the fetched results.
  ///   - predicate: An
  ///     <https://developer.apple.com/documentation/Foundation/NSPredicate>
  ///     instance that defines logical conditions used to filter the fetched
  ///     results.
  ///   - animation: The animation to use for user interface changes that
  ///     result from changes to the fetched results.
  @MainActor @preconcurrency public init(sortDescriptors: [SortDescriptor<Result>], predicate: NSPredicate? = nil, animation: Animation? = nil) {

    self.buildFetchRequest = {
      let fetchRequest = NSFetchRequest<Result>()
      fetchRequest.entity = Result.entity()
      fetchRequest.sortDescriptors = sortDescriptors.map { NSSortDescriptor($0) }
      fetchRequest.predicate = predicate
      return fetchRequest
    }
    self.storage = SwiftUI.FetchRequest(sortDescriptors: sortDescriptors, predicate: predicate, animation: animation)
  }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension FetchRequest : Sendable {
}

// MARK: - Helper

private extension FetchRequest {

  func buildFetchedResults() -> FetchedResults<Result> {
    if TestSupport.isRunningUnitTest {
      if let container: NSPersistentContainer = TestSupport.getInjected(for: TestSupport.persistentContainerKey) {
        let results = FetchedResults(context: container.viewContext, fetchRequest: self.buildFetchRequest())
        self.results = results
        return results
      }

      NotificationCenter.default.post(name: .swiftUITestSupportMissingCoreDataInjection, object: nil)
    }

    let results = FetchedResults(results: self.storage.wrappedValue)
    self.results = results
    return results
  }
}
