import Foundation
import CoreData
import SwiftAppUtilities

struct OpenMeteoWeatherService: Sendable {

  private let httpClient: HTTPClient
  private let locationService: LocationService
  private let coreDataContainer: NSPersistentContainer

  init(httpClient: HTTPClient, locationService: LocationService, coreDataContainer: NSPersistentContainer) {
    self.httpClient = httpClient
    self.locationService = locationService
    self.coreDataContainer = coreDataContainer
  }

  func updateForecastForCurrentLocation() async throws(WeatherServiceError) -> WeatherServiceLocation {
    let location = try await withThrowingError(WeatherServiceError.location) {
      try await self.locationService.getLatestAvailableLocation()
    }

    let payload = try await withThrowingError(WeatherServiceError.network) {
      try await self.httpClient.request(
        OpenMeteoAPI.getOpenMeteoForecastRequest,
        payload: GetWeatherPayload(latitude: location.latitude, longitude: location.longitude)
      )
    }

    guard let forecast = payload.hourly, let temperatureUnit = payload.hourlyUnits?.temperature2m
    else { throw WeatherServiceError.emptyData }

    let context = self.coreDataContainer.newBackgroundContext()

    try await withThrowingError(WeatherServiceError.persistence) {
      try await context.perform {
        try zip(zip(forecast.time, forecast.temperature2m), forecast.weatherCode)
          .map { ($0.0, $0.1, $1) }
          .forEach { time, temperature, weatherCode in
            let id = "\(location.name)-\(time)"

            let request = Forecast.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == '\(id)'")

            let cdForecast = try context.fetch(request).first ?? Forecast(context: context)

            cdForecast.identifier = id
            cdForecast.date = Date(timeIntervalSince1970: TimeInterval(time))
            cdForecast.location = location.name
            cdForecast.weatherRawValue = Int64(weatherCode)
            cdForecast.serviceRawValue = WeatherServiceCode.openMeteo.rawValue
            cdForecast.temperature = temperature
            cdForecast.temperatureUnit = temperatureUnit
          }

        if context.hasChanges { try context.save() }
      }
    }

    return WeatherServiceLocation(name: location.name)
  }
}

extension Forecast {

  struct WeatherRepresentation {
    let description: String
    let sfSymbol: String
  }
}

extension Forecast {

  var weatherRepresentation: WeatherRepresentation {
    switch WeatherServiceCode(rawValue: self.serviceRawValue) ?? .openMeteo {
    case .openMeteo:
      let code = OpenMeteoWeatherCode(rawValue: Int(self.weatherRawValue)) ?? .unknown
      return WeatherRepresentation(description: code.description, sfSymbol: code.sfSymbol)
    }
  }
}

extension OpenMeteoWeatherCode {

  var sfSymbol: String {
    switch self {
    case .clearSky:
      return "sun.max"
    case .mainlyClear:
      return "sun.max"
    case .partlyCloudy:
      return "cloud.sun"
    case .overcast:
      return "cloud"
    case .fog, .depositingRimeFog:
      return "cloud.fog"
    case .drizzleLight, .drizzleModerate, .drizzleDense:
      return "cloud.drizzle"
    case .freezingDrizzleLight, .freezingDrizzleDense:
      return "cloud.sleet"
    case .rainSlight, .rainModerate:
      return "cloud.rain"
    case .rainHeavy:
      return "cloud.heavyrain"
    case .freezingRainLight, .freezingRainHeavy:
      return "cloud.sleet"
    case .snowFallSlight, .snowFallModerate:
      return "cloud.snow"
    case .snowFallHeavy:
      return "cloud.snow.fill"
    case .snowGrains:
      return "snow"
    case .rainShowersLight, .rainShowersModerate:
      return "cloud.rain"
    case .rainShowersViolent:
      return "cloud.heavyrain"
    case .snowShowersLight, .snowShowersHeavy:
      return "cloud.snow"
    case .thunderstorm:
      return "cloud.bolt"
    case .thunderstormWithSlightHail, .thunderstormWithHeavyHail:
      return "cloud.bolt.rain"
    case .unknown:
      return "questionmark"
    }
  }

  var description: String {
    switch self {
    case .clearSky:
      return "Clear sky"
    case .mainlyClear:
      return "Mainly clear"
    case .partlyCloudy:
      return "Partly cloudy"
    case .overcast:
      return "Overcast"
    case .fog:
      return "Fog"
    case .depositingRimeFog:
      return "Depositing rime fog"
    case .drizzleLight:
      return "Drizzle: Light intensity"
    case .drizzleModerate:
      return "Drizzle: Moderate intensity"
    case .drizzleDense:
      return "Drizzle: Dense intensity"
    case .freezingDrizzleLight:
      return "Freezing Drizzle: Light intensity"
    case .freezingDrizzleDense:
      return "Freezing Drizzle: Dense intensity"
    case .rainSlight:
      return "Rain: Slight intensity"
    case .rainModerate:
      return "Rain: Moderate intensity"
    case .rainHeavy:
      return "Rain: Heavy intensity"
    case .freezingRainLight:
      return "Freezing Rain: Light intensity"
    case .freezingRainHeavy:
      return "Freezing Rain: Heavy intensity"
    case .snowFallSlight:
      return "Snow fall: Slight intensity"
    case .snowFallModerate:
      return "Snow fall: Moderate intensity"
    case .snowFallHeavy:
      return "Snow fall: Heavy intensity"
    case .snowGrains:
      return "Snow grains"
    case .rainShowersLight:
      return "Rain showers: Slight"
    case .rainShowersModerate:
      return "Rain showers: Moderate"
    case .rainShowersViolent:
      return "Rain showers: Violent"
    case .snowShowersLight:
      return "Snow showers: Slight"
    case .snowShowersHeavy:
      return "Snow showers: Heavy"
    case .thunderstorm:
      return "Thunderstorm: Slight or moderate"
    case .thunderstormWithSlightHail:
      return "Thunderstorm with slight hail"
    case .thunderstormWithHeavyHail:
      return "Thunderstorm with heavy hail"
    case .unknown:
      return "Unknown Weather"
    }
  }
}
