import Foundation
import Testing
import CoreLocation
@testable import SimpleWeather

@Suite
struct CoreLocationServiceTests {

  @Test
  func Given_CoreLocationService_When_GettingCurrentAuthorizationNotDetermined_Then_MapToUnkwnown() async throws {

    let manager = MockLocationManager(authorizationStatus: .notDetermined)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .unknown)
  }

  @Test
  func Given_CoreLocationService_When_GettingCurrentAuthorizationDenied_Then_MapToDenied() async throws {

    let manager = MockLocationManager(authorizationStatus: .denied)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .denied)
  }

  @Test
  func Given_CoreLocationService_When_GettingCurrentAuthorizationRestricted_Then_MapToRestricted() async throws {

    let manager = MockLocationManager(authorizationStatus: .restricted)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .restricted)
  }

  @Test
  func Given_CoreLocationService_When_GettingCurrentAuthorizationWhenInUse_Then_MapToGranted() async throws {

    let manager = MockLocationManager(authorizationStatus: .authorizedWhenInUse)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .granted)
  }

  @Test
  func Given_CoreLocationService_When_GettingCurrentAuthorizationNotDetermined_Then_MapToGranted() async throws {

    let manager = MockLocationManager(authorizationStatus: .authorizedAlways)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .granted)
  }

  @Test
  func Given_CoreLocationService_When_RequestingAuthorization_Then_ReceiveNewStatus() async throws {

    let manager = MockLocationManager(postAuthorizationRequestStatus: .authorizedWhenInUse)
    let sut = CoreLocationService(locationManager: manager)

    #expect(sut.currentAuthorization == .unknown)

    try await sut.requestAuthorization()

    #expect(sut.currentAuthorization == .granted)
  }

  @Test
  func Given_CoreLocationService_When_RequestingLocationButNotAuthorized_Then_ThrowsError() async throws {

    let manager = MockLocationManager(authorizationStatus: .denied)
    let sut = CoreLocationService(locationManager: manager)

    await #expect(throws: LocationServiceError.self) { try await sut.getLatestAvailableLocation() }
  }

  @Test
  func Given_CoreLocationService_When_RequestingLocationIsAuthorizedButGeocoderFail_Then_ThrowsError() async throws {

    let manager = MockLocationManager(authorizationStatus: .authorizedWhenInUse)
    let sut = CoreLocationService(locationManager: manager, geocoder: MockGeocoder())

    await #expect(throws: LocationServiceError.self) { try await sut.getLatestAvailableLocation() }
  }

  @Test
  func Given_CoreLocationService_When_RequestingLocationIsAuthorizedButGeocoderSucceed_Then_ReceiveLocation() async throws {

    let manager = MockLocationManager(authorizationStatus: .authorizedWhenInUse)
    manager.mockLocation = CLLocation(latitude: 10, longitude: 20)
    let sut = CoreLocationService(locationManager: manager, geocoder: MockGeocoder(placemark: Placemark(name: "test")))

    let location = try await sut.getLatestAvailableLocation()

    #expect(location == Location(name: "test", latitude: 10, longitude: 20))
  }
}
