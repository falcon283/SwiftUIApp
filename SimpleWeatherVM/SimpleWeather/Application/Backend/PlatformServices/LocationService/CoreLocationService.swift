import Foundation
import CoreLocation
import SwiftAppUtilities

struct CoreLocationService: Sendable {

  @ThreadSafe
  private var locationManager: CLLocationManager

  @ThreadSafe
  private var geocoder: Geocoder

  @ThreadSafe
  private var authorizationContinuation: CheckedContinuation<(), Error>?

  @ThreadSafe
  private var locationContinuation: CheckedContinuation<CLLocation, Error>?

  @ThreadSafe
  private var locationManagerDelegate: LocationManagerDelegate

  init(locationManager: CLLocationManager = CLLocationManager(), geocoder: Geocoder = CLGeocoder()) {
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    self._locationManager = ThreadSafe(locationManager)
    self._geocoder = ThreadSafe(geocoder)
    self._locationManagerDelegate = ThreadSafe(
      LocationManagerDelegate(
        authorizationContinuation: self._authorizationContinuation,
        locationContinuation: self._locationContinuation
      )
    )
    self.locationManager.delegate = self.locationManagerDelegate
  }
}

extension CoreLocationService {

  var currentAuthorization: LocationAuthorization {
    self.locationManager.authorizationStatus.asPermission
  }

  func requestAuthorization() async throws {
    if self.currentAuthorization == .unknown {
      defer { self.$authorizationContinuation.assign(nil) }
      try await withCheckedThrowingContinuation { continuation in
        self.$authorizationContinuation.assign(continuation)
        self.locationManager.requestWhenInUseAuthorization()
      }
    } else {
      throw LocationServiceError.missingAuthorization(self.currentAuthorization)
    }
  }

  func getLatestAvailableLocation() async throws -> Location {
    defer { self.$locationContinuation.assign(nil) }
    guard self.currentAuthorization == .granted
    else { throw LocationServiceError.missingAuthorization(self.currentAuthorization) }

    let location = try await withCheckedThrowingContinuation { continuation in
      self.$locationContinuation.assign(continuation)
      self.locationManager.requestLocation()
    }

    let placemark = try await self.geocoder.reverseGeocodeLocation(location).first

    return Location(name: placemark.displayName, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
  }
}

private extension CoreLocationService {

  final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {

    @ThreadSafe
    private var authorizationContinuation: CheckedContinuation<(), Error>?

    @ThreadSafe
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    init(
      authorizationContinuation: ThreadSafe<CheckedContinuation<(), Error>?>,
      locationContinuation: ThreadSafe<CheckedContinuation<CLLocation, Error>?>
    ) {
      self._authorizationContinuation = authorizationContinuation
      self._locationContinuation = locationContinuation
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      let permission = manager.authorizationStatus.asPermission
      self.authorizationContinuation?
        .resume(with: permission == .granted ? .success(()) : .failure(LocationServiceError.missingAuthorization(permission)))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
      self.locationContinuation?.resume(throwing: LocationServiceError.locationNotFound)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.last {
        self.locationContinuation?.resume(
          returning: location
        )
      } else {
        self.locationContinuation?.resume(throwing: LocationServiceError.locationNotFound)
      }
    }
  }
}

private extension CLAuthorizationStatus {
  var asPermission: LocationAuthorization {
    switch self {
    case .notDetermined:
      return .unknown

    case .authorizedAlways, .authorizedWhenInUse:
      return .granted

    case .denied:
      return .denied

    case .restricted:
      return .restricted

    @unknown default:
      return .granted
    }
  }
}

private extension Optional where Wrapped == Placemark {

  var displayName: String {
    self?.subLocality ?? self?.locality ?? self?.subAdministrativeArea ?? self?.administrativeArea ?? self?.name ?? "Unknown"
  }
}
