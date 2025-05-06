import Foundation
import CoreData
import SwiftAppUtilities

final class CoreDataStack: @unchecked Sendable {

  let name: String
  let readOnly: Bool

  /// Can be used to further apply customizations to the just loaded NSPersistentContainer.
  @ThreadSafe
  private var onPersistentContainerLoaded: ((NSPersistentContainer) -> Void)?

  /// Holds the viewContext synchronization via notification center.
  @ThreadSafe
  private var onSynchronizationNotificationToken: NSObjectProtocol?

  // Create a persistent container as a lazy variable to defer instantiation until its first use.
  lazy var persistentContainer: NSPersistentContainer = {

    // Pass the data model filename to the container’s initializer.
    let container = NSPersistentContainer(name: self.name)

    if self.readOnly {
      container.persistentStoreDescriptions.forEach { storeDescription in
        storeDescription.type = NSInMemoryStoreType
        storeDescription.shouldAddStoreAsynchronously = false
      }
    }

    // Load any persistent stores, which creates a store if none exists.
    container.loadPersistentStores { storeDescription, error in

      if let error {
        // Handle the error appropriately. However, it's useful to use
        // `fatalError(_:file:line:)` during development.
        fatalError("Failed to load persistent stores: \(error.localizedDescription)")
      }
    }

    // Merge back changes synchronizing the viewContext when any other background context gets saved.
    self.$onSynchronizationNotificationToken.assign(
      NotificationCenter.default.addObserver(
        forName: .NSManagedObjectContextDidSave,
        object: nil,
        queue: .main
      ) { [container] notification in
        guard let object = notification.object as? NSManagedObjectContext, object != container.viewContext else { return }
        container.viewContext.mergeChanges(fromContextDidSave: notification)
      }
    )

    self.onPersistentContainerLoaded?(container)
    self.$onPersistentContainerLoaded.assign(nil)

    return container
  }()

  init(name: String, readOnly: Bool = false, onPersistentContainerLoaded: ((NSPersistentContainer) -> Void)? = nil) {
    self.name = name
    self.readOnly = readOnly
    self.$onPersistentContainerLoaded.assign(onPersistentContainerLoaded)
  }

  deinit {
    guard let token = self.onSynchronizationNotificationToken else { return }
    NotificationCenter.default.removeObserver(token)
  }
}
