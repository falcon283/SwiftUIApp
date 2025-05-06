import Foundation
import Testing
@testable import SimpleWeather

extension CoreDataSuite {

  struct OpenMeteoWeatherServiceTests {}
}

extension CoreDataSuite.OpenMeteoWeatherServiceTests {

  @Test
  func Given_OpenMeteoWeatherService_When_UpdatingForecastLocationFails_Then_ReturnError() async throws {

    let coreData = CoreDataStack(name: "Weather", readOnly: true)
    let client = PreviewHTTPClient()

    let sut = OpenMeteoWeatherService(
      httpClient: client,
      locationService: LocationService(
        currentAuthorization: { .denied },
        requestAuthorization: { },
        getLatestAvailableLocation: { Location(name: "test", latitude: 10, longitude: 20) }
      ),
      coreDataContainer: coreData.persistentContainer
    )

    await #expect(throws: WeatherServiceError.self) { try await sut.updateForecastForCurrentLocation() }
  }

  @Test
  func Given_OpenMeteoWeatherService_When_UpdatingForecastFails_Then_ReturnError() async throws {

    let coreData = CoreDataStack(name: "Weather", readOnly: true)
    let client = PreviewHTTPClient()

    let sut = OpenMeteoWeatherService(
      httpClient: client,
      locationService: LocationService(
        currentAuthorization: { .granted },
        requestAuthorization: { },
        getLatestAvailableLocation: { Location(name: "test", latitude: 10, longitude: 20) }
      ),
      coreDataContainer: coreData.persistentContainer
    )

    await #expect(throws: WeatherServiceError.self) { try await sut.updateForecastForCurrentLocation() }
  }

  @Test
  func Given_OpenMeteoWeatherService_When_UpdatingForecastSucceed_Then_ReturnLocation() async throws {

    let coreData = CoreDataStack(name: "Weather", readOnly: true)
    let client = PreviewHTTPClient()
      .add(
        request: OpenMeteoAPI.getOpenMeteoForecastRequest,
        result: .success(
          .init(
            latitude: 10,
            longitude: 20,
            elevation: 30,
            generationTimeMs: 0,
            utcOffsetSeconds: 0,
            timezone: "GMT",
            timezoneAbbreviation: "GMT",
            hourly: .init(time: [1], temperature2m: [20], weatherCode: [1]),
            hourlyUnits: .init(
              temperature2m: "C"
            )
          )
        )
      )

    let sut = OpenMeteoWeatherService(
      httpClient: client,
      locationService: LocationService(
        currentAuthorization: { .granted },
        requestAuthorization: { },
        getLatestAvailableLocation: { Location(name: "test", latitude: 10, longitude: 20) }
      ),
      coreDataContainer: coreData.persistentContainer
    )

    // Initially Empty
    await {
      let fetchRequest = Forecast.fetchRequest()
      let context = coreData.persistentContainer.newBackgroundContext()

      await #expect(context.perform { (try? context.fetch(fetchRequest)) ?? [Forecast]() }.isEmpty)
    }()

    let result = try await sut.updateForecastForCurrentLocation()

    #expect(result == WeatherServiceLocation(name: "test"))

    // CoreData Filled
    await {
      let fetchRequest = Forecast.fetchRequest()
      let context = coreData.persistentContainer.newBackgroundContext()

      await #expect(context.perform { (try? context.fetch(fetchRequest)) ?? [Forecast]() }.isEmpty == false)
    }()
  }
}
