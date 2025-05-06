import Foundation
import CoreData
import SwiftAppUtilities
import UIKit

extension AppContainer {

  static func preview() -> AppContainer {

    let coreDataStack = CoreDataStack(name: "Weather", readOnly: true) { AppContainer.addMockData(in: $0.viewContext) }
    let locationService = LocationService(
      currentAuthorization: { .granted },
      requestAuthorization: { },
      getLatestAvailableLocation: { Location(name: "Barcelona", latitude: 41.392418, longitude: 2.194475) }
    )

    let userDefaults: ThreadSafe<[String: Any]> = .init([:])

    return AppContainer(
      userDefaults: UserDefaultsService(
        get: { userDefaults.wrappedValue[$0] },
        set: { key, newValue in userDefaults.projectedValue.perform { $0[key] = newValue } }
      ),
      openURL: OpenURLService { url in Task { @MainActor in UIApplication.shared.open(url) } },
      locationService: locationService,
      weatherService: WeatherService(
        updateForecastForCurrentLocation: { WeatherServiceLocation(name: "Mock Location") }
      ),
      persistenceContainer: { coreDataStack.persistentContainer
      }
    )
  }
}

private extension AppContainer {

  static func addMockData(in context: NSManagedObjectContext) {
    let now = Date.now
    (0..<48).forEach { index in
      let forecast = Forecast(context: context)
      forecast.identifier = "\(index)"
      forecast.date = now.addingTimeInterval(TimeInterval(index * 3600))
      forecast.location = "Mock Location"
      forecast.weatherService = .openMeteo
      forecast.openMeteoWeather = .allCases.randomElement()!
      forecast.temperature = Double.random(in: 10...20)
      forecast.temperatureUnit = "Cº"
    }

    try? context.save()
  }
}
