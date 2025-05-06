import Foundation
import SwiftUI
import CoreData

extension EnvironmentValues {
  @Entry
  var appContainer: AppContainer = AppContainer.preview()
}

extension View {
  nonisolated func environment(_ value: AppContainer) -> some View {
    self
      .environment(\.appContainer, value)
      .environment(\.managedObjectContext, value.viewContext)
  }
}

struct AppContainer: Sendable {

  var locationService: LocationService
  var weatherService: WeatherService

  let persistenceContainer: @Sendable () -> NSPersistentContainer
}

extension AppContainer {

  var viewContext: NSManagedObjectContext {
    self.persistenceContainer().viewContext
  }
}
