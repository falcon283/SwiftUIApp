import Foundation
import CoreLocation

protocol Geocoder {
  func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Placemark]
}

extension CLGeocoder: Geocoder {

  func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Placemark] {
    try await self.reverseGeocodeLocation(location).map(Placemark.init)
  }
}

// MARK: - Placemark

struct Placemark {
  let subLocality: String?
  let locality: String?
  let subAdministrativeArea: String?
  let administrativeArea: String?
  let name: String?

  init(
    subLocality: String? = nil,
    locality: String? = nil,
    subAdministrativeArea: String? = nil,
    administrativeArea: String? = nil,
    name: String? = nil
  ) {
    self.subLocality = subLocality
    self.locality = locality
    self.subAdministrativeArea = subAdministrativeArea
    self.administrativeArea = administrativeArea
    self.name = name
  }
}

private extension Placemark {

  init(_ placemark: CLPlacemark) {
    self.subLocality = placemark.subLocality
    self.locality = placemark.locality
    self.subAdministrativeArea = placemark.subAdministrativeArea
    self.administrativeArea = placemark.administrativeArea
    self.name = placemark.name
  }
}
