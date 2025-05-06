import Foundation
import CoreLocation

final class MockLocationManager: CLLocationManager {

  private var _authorizationStatus: CLAuthorizationStatus
  override var authorizationStatus: CLAuthorizationStatus {
    self._authorizationStatus
  }

  init(
    authorizationStatus: CLAuthorizationStatus = .notDetermined,
    postAuthorizationRequestStatus: CLAuthorizationStatus = .authorizedWhenInUse
  ) {
    self._authorizationStatus = authorizationStatus
    self.postAuthorizationRequestStatus = postAuthorizationRequestStatus
  }

  let postAuthorizationRequestStatus: CLAuthorizationStatus

  override func requestWhenInUseAuthorization() {
    guard self.authorizationStatus == .notDetermined else { return }
    self._authorizationStatus = postAuthorizationRequestStatus
    self.delegate?.locationManagerDidChangeAuthorization?(self)
  }

  var mockLocation: CLLocation?

  override func requestLocation() {
    if let mockLocation {
      self.delegate?.locationManager?(self, didUpdateLocations: [mockLocation])
    } else {
      self.delegate?.locationManager?(
        self,
        didFailWithError: NSError(domain: kCLErrorDomain, code: CLError.locationUnknown.rawValue)
      )
    }
  }
}

