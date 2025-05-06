import Foundation

struct Location: Equatable {
  let name: String
  
  let latitude: Double
  let longitude: Double
}

enum LocationAuthorization {
  case granted
  case restricted
  case denied
  case unknown
}

enum LocationServiceError: Error {
  case locationNotFound
  case missingAuthorization(LocationAuthorization)
}

struct LocationService: Sendable {

  var currentAuthorization: @Sendable () -> LocationAuthorization

  var requestAuthorization: @Sendable () async throws -> Void

  var getLatestAvailableLocation: @Sendable () async throws -> Location
}
