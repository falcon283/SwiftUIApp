import Foundation
import SwiftAppUtilities

extension AppContainer {

  static func live() async -> AppContainer {
    let coreDataStack = CoreDataStack(name: "Weather")
    let httpClient = URLSessionHTTPClient(
      baseURL: URL(string: "https://api.open-meteo.com")!,
      defaultHeaders: [:],
      modifiers: [],
      dataFor: URLSession.shared.data(for:)
    )

    let locationService = await Task { @MainActor in
      // CLLocationManager Requires main thread to let the Delegate works properly.
      let coreLocationService = CoreLocationService()
      return LocationService(
        currentAuthorization: { coreLocationService.currentAuthorization },
        requestAuthorization: { try await coreLocationService.requestAuthorization() },
        getLatestAvailableLocation: { try await coreLocationService.getLatestAvailableLocation() }
      )
    }.value

    let openMeteoService = OpenMeteoWeatherService(httpClient: httpClient, locationService: locationService, coreDataContainer: coreDataStack.persistentContainer)

    let userDefault = ThreadSafe(UserDefaults())

    return AppContainer(
      userDefaults: UserDefaultsService(
        get: { userDefault.wrappedValue.value(forKey: $0) },
        set: { key, value in userDefault.projectedValue.perform { $0.set(value, forKey: key)} }
      ),
      openURL: OpenURLService { print("URL: \($0) opened") },
      locationService: locationService,
      weatherService: WeatherService(
        updateForecastForCurrentLocation: { try await openMeteoService.updateForecastForCurrentLocation() }
      ),
      persistenceContainer: { coreDataStack.persistentContainer }
    )
  }
}
