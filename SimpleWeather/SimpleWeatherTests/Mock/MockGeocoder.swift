import Foundation
import CoreLocation
import SwiftAppUtilities
@testable import SimpleWeather

struct MockGeocoder: Geocoder {

  @ThreadSafe
  var placemark: Placemark?

  init(placemark: Placemark? = nil) {
    self._placemark = ThreadSafe(placemark)
  }

  func reverseGeocodeLocation(_ location: CLLocation) async throws -> [Placemark] {
    guard let placemark else { throw NSError(domain: kCLErrorDomain, code: CLError.geocodeFoundNoResult.rawValue) }
    return [placemark]
  }
}
