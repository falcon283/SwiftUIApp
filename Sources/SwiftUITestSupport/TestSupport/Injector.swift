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

public struct Injector: Sendable {

  @ThreadSafe
  var storage: [String: Any] = [TestSupport.unitTestKey: true]

  public nonmutating func inject<T>(_ value: T, for key: String) {
    self.$storage.perform { $0[key] = value }
  }
}

// MARK: - Environment

public extension Injector {
  
  @discardableResult
  nonmutating func environment<T>(_ keyPath: KeyPath<EnvironmentValues, T>, _ value: T) -> Injector {
    let key = TestSupport.environmentKey(for: keyPath)
    self.inject(value, for: key)
    return self
  }
  
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
  
  @discardableResult
  nonmutating func environmentObject<T: ObservableObject>(_ object: T) -> Injector {
    let key = TestSupport.environmentObjectKey(for: T.self)
    self.inject(object, for: key)
    return self
  }
}

// MARK: - Storage

public extension Injector {
  
  @discardableResult
  nonmutating func storage<T>(_ value: T, for key: String) -> Injector {
    let key = TestSupport.storageKey(for: key)
    self.inject(value, for: key)
    return self
  }
}

// MARK: - Focus

public extension Injector {
  
  @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
  @discardableResult
  nonmutating func focusedValue<Value>(_ keyPath: WritableKeyPath<FocusedValues, Value?>, _ value: Value) -> Injector {
    let key = TestSupport.focusedValueKey(for: keyPath)
    self.inject(value, for: key)
    return self
  }
  
  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @discardableResult
  nonmutating func focusedObject<T>(_ object: T) -> Injector where T : ObservableObject {
    let key = TestSupport.focusedObjectKey(for: T.self)
    self.inject(object, for: key)
    return self
  }
  
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

public final class CoreDataInjector {

  private let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
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
