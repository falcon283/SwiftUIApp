import Foundation
import CoreData

struct WeatherServiceLocation: Equatable {
  let name: String
}

enum WeatherServiceError: Error {
  case location(Error)
  case network(Error)
  case persistence(Error)
  case emptyData
}

struct WeatherService: Sendable {
  var updateForecastForCurrentLocation: @Sendable () async throws -> WeatherServiceLocation
}
