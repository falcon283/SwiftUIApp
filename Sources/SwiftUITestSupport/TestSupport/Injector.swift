public import CoreData
public import SwiftUI
internal import SwiftAppUtilities

extension Notification.Name {
  static let swiftUITestSupportMissingInjection = Notification.Name("_SwiftUIAppTestSupport_MissingInjection")
  static let swiftUITestSupportMissingCoreDataInjection = Notification.Name("_SwiftUITestSupportMissingCoreDataInjection")
}

extension Notification {
  static let swiftUITestSupportMissingInjectionKeyDescription = "_SwiftUITestSupportMissingInjectionKeyDescription"
}

/// The injector object is used to support dependency injection while running Unit Tests.
///
/// You never create an Injector object but rather you receive it when using ``given(_:withDependencies:expect:)``.
/// The `given` function will setup the environment so that all the SwiftUI Shadows will be able to gather the configured injections.
public struct Injector: Sendable {

  @ThreadSafe
  var storage: [String: Any] = [TestSupport.unitTestKey: true]

  /// This method could be used in the remote possibility you are extending `Injector` because your codebase implements a custom `DynamicProperty`
  /// property wrapper and you want to enable it for Unit Testing purpose.
  ///
  /// This will be needed because `DynamicProperty` is a very special type in SwiftUI which is made accessible only in the View body. If not it will give you
  /// a runtime warning if inspected during Unit Tests.
  /// If you fall into this case, your implementation should also leverage ``TestSupport/isRunningUnitTest``.
  ///
  /// - Parameters:
  ///   - value: The value to inject.
  ///   - key: The key used to associate the object.
  ///
  /// - Note: If your custom `DynamicProperty` implementation is using `@Environment` `@EnvironmentObject` or any other provided shadows,
  /// they will be automatically shadowed so you don't have to care about them unless you explicitly use `@SwiftUI.Environment`.
  public nonmutating func inject<T>(_ value: T, for key: String) {
    self.$storage.perform { $0[key] = value }
  }
}

// MARK: - Environment

public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `EnvironmentValues` keyPath into the Shadows.
  ///
  /// - Parameters:
  ///   - keyPath: The keyPath for the injection. Must be exactly the same as the one used in your implementation.
  ///   - value: The value to inject
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `keyPath` as the implementation.
  /// If not the test will fail and will point you out the missing keyPath.
  @discardableResult
  nonmutating func environment<T>(_ keyPath: KeyPath<EnvironmentValues, T>, _ value: T) -> Injector {
    let key = TestSupport.environmentKey(for: keyPath)
    self.inject(value, for: key)
    return self
  }
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `Observable` into the Shadows.
  ///
  /// - Parameter observable: The `Observable` to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `T` as the implementation.
  /// If not the test will fail and will point you out the missing type.
  @available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
  @discardableResult
  nonmutating func environment<T: Observable & AnyObject>(_ observable: T) -> Injector {
    let key = TestSupport.environmentKey(for: T.self)
    let keyOptional = TestSupport.environmentKey(for: T?.self)
    self.inject(observable, for: key)
    self.inject(observable, for: keyOptional)
    return self
  }
}

// MARK: - EnvironmentObject

public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `ObservableObject` into the Shadows.
  ///
  /// - Parameter object: The `ObservableObject` to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `T` as the implementation.
  /// If not the test will fail and will point you out the missing type.
  @discardableResult
  nonmutating func environmentObject<T: ObservableObject>(_ object: T) -> Injector {
    let key = TestSupport.environmentObjectKey(for: T.self)
    self.inject(object, for: key)
    return self
  }
}

// MARK: - Storage

public extension Injector {
  
  /// This is used to inject a value retrieved by ``AppStorage`` or ``SceneStorage`` Shadows.
  ///
  /// The injected value mimic a different value into `UserDefault`. If present the ``AppStorage`` and ``SceneStorage``
  /// will prefer the injected value over the default value as it would happen in real case scenario.
  ///
  /// - Parameter value: The object to inject.
  /// - Parameter key: The storage key of the ``AppStorage`` or ``SceneStorage``.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Note: The injected value type is inferred. Make sure to inject the proper one if you are using type inference.
  /// As example if you inject `.storage(1, for: "doubleKey")` the value inferred is `Int` and thus if the implementation key is expecting Double
  /// the injection lookup will fail. In this case you should inject `1.0` or `Double(1)` instead.
  ///
  /// - Warning: You must use exactly the same `key` as the implementation.
  @discardableResult
  nonmutating func storage<T>(_ value: T, for key: String) -> Injector {
    let key = TestSupport.storageKey(for: key)
    self.inject(value, for: key)
    return self
  }
}

// MARK: - Focus

public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject a `FocusedValues` keyPath into the Shadows.
  ///
  /// - Parameters:
  ///   - keyPath: The keyPath for the injection. Must be exactly the same as the one used in your implementation.
  ///   - value: The value to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  ///
  /// - Warning: You must use exactly the same `keyPath` as the implementation.
  /// If not the test will fail and will point you out the missing keyPath.
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @discardableResult
  nonmutating func focusedValue<Value>(_ keyPath: WritableKeyPath<FocusedValues, Value?>, _ value: Value) -> Injector {
    let key = TestSupport.focusedValueKey(for: keyPath)
    self.inject(value, for: key)
    return self
  }
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `ObservableObject` keyPath into the Shadows.
  ///
  /// - Parameter object: The object to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @discardableResult
  nonmutating func focusedObject<T>(_ object: T) -> Injector where T : ObservableObject {
    let key = TestSupport.focusedObjectKey(for: T.self)
    self.inject(object, for: key)
    return self
  }
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `ObservableObject?` keyPath into the Shadows.
  ///
  /// - Parameter object: The object to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  @discardableResult
  nonmutating func focusedObject<T>(_ object: T?) -> Injector where T : ObservableObject {
    let key = TestSupport.focusedObjectKey(for: T.self)
    if let object {
      self.inject(object, for: key)
    } else {
      self.inject(Optional<T>.none, for: key)
    }
    return self
  }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension Injector {
  
  /// Like the  SwiftUI `View` counterpart, it is used to inject an `Observable?` keyPath into the Shadows.
  ///
  /// - Parameter object: The object to inject.
  /// - Returns: The modified `Injector` so to continue the injection chain easily.
  @discardableResult
  nonmutating func focusedValue<T>(_ object: T?) -> Injector where T : AnyObject, T : Observable {
    let key = TestSupport.focusedValueKey(for: T.self)
    if let object {
      self.inject(object, for: key)
    } else {
      self.inject(Optional<T>.none, for: key)
    }
    return self
  }
}

// MARK: - CoreData

public extension Injector {

  static let coreDataNotLoadedMessage = """
  💥 Core Data Stack is missing!!!
  Injector.startCoreData(name:bundle:) call is missing from the Injector modifier closure of the given(_:withDependencies:expect:)
  """
  
  /// This method is used to bootstrap the CoreData during the ``given(_:withDependencies:expect:)`` execution.
  /// If you are using CoreData DynamicProperties in your implementation such ``FetchRequest`` or ``SectionedFetchRequest`` then it's mandatory
  /// to call this method or CoreData will crash because will not be able to determine the Model.
  ///
  /// CoreData will be loaded as in memory only.
  /// You have chance to inject objects for the test purpose by calling ``CoreDataInjector/insert(_:update:)``.
  ///
  /// - Parameters:
  ///   - name: The CoreData Model name to load.
  ///   - bundle: The bindle where the Model is located.
  /// - Returns: A ``CoreDataInjector`` that should be used to insert you custom `NSManagedObject`s.
  @MainActor
  @discardableResult
  nonmutating func startCoreData(
    named name: String,
    bundle: Bundle
  ) async throws -> CoreDataInjector {

    enum CoreDataError: Error, CustomDebugStringConvertible {

      case modelNotFound(String)
      case persistentStoreDescriptionNotFound
      case unableToLoad(Error)

      var debugDescription: String {
        switch self {
        case let .modelNotFound(name):
          return "CoreData Model named \(name).momd not found."
        case .persistentStoreDescriptionNotFound:
          return "Unable to find the persistentStoreDescription."
        case let .unableToLoad(error):
          return "Unable to load the persistentStores: \(error)"
        }
      }
    }

    guard let modelUrl = bundle.url(forResource: name, withExtension: "momd"),
          let model = NSManagedObjectModel(contentsOf: modelUrl)
    else { throw CoreDataError.modelNotFound(name) }

    let container = NSPersistentContainer(name: name, managedObjectModel: model)

    guard let storeDescription = container.persistentStoreDescriptions.first
    else { throw CoreDataError.persistentStoreDescriptionNotFound }

    storeDescription.type = NSInMemoryStoreType
    storeDescription.shouldAddStoreAsynchronously = false
    if #available(iOS 16.0, *) {
      storeDescription.url = URL(filePath: "/dev/null")
    } else {
      storeDescription.url = URL(fileURLWithPath: "/dev/null")
    }

    do {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        container.loadPersistentStores { _, error in
          if let error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume()
          }
        }
      }
    } catch {
      throw CoreDataError.unableToLoad(error)
    }

    let injector = CoreDataInjector(context: container.viewContext)

    self.inject(container, for: TestSupport.persistentContainerKey)

    return injector
  }
}

/// An helper used to Inject CoreData `NSManagedObject`s into the loaded in memory Model.
public final class CoreDataInjector {

  private let context: NSManagedObjectContext
  
  /// Designated initializer
  ///
  /// - Parameter context: The context to use to insert the objects.
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  /// You use this method to modify the content of the in memory CoreData Model just loaded.
  ///
  /// It is not mandatory to call this method if your specific unit test function does not assert the presence of objects inside the Model.
  ///
  /// - Parameters:
  ///   - type: The type of object to create.
  ///   - update: A function offer you a brand new just created `T` so you can modify it's properties before it get's saved.
  /// - Returns: The modified `CoreDataInjector` so to continue the injection chain easily by adding more objects.
  @discardableResult
  public func insert<T: NSManagedObject>(_ type: T.Type, update: (T) -> Void) -> CoreDataInjector {
    let object = type.init(context: self.context)
    update(object)
    return self
  }

  deinit {
    try? self.context.save()
  }
}
