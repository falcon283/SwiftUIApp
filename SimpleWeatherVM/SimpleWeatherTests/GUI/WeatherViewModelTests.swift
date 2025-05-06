import Foundation
import Testing
import SwiftUIApp
import SwiftUITestSupport
import SwiftAppUtilities
@testable import SimpleWeather

extension CoreDataSuite {

  @MainActor
  struct WeatherViewModelTests { }
}

extension CoreDataSuite.WeatherViewModelTests {

  @Test
  func Given_WeatherViewModel_When_Created_Then_IsInLoadingStatus() async throws {

    var appContainer = AppContainer.preview()
    appContainer.weatherService.updateForecastForCurrentLocation = { .init(name: "test") }

    let sut = WeatherViewModel(appContainer: appContainer)

    #expect(sut.status == .loading)
  }

  @Test
  func Given_WeatherViewModel_When_LoadIsNotifiedButEmptyForecast_Then_DataLoadedMatch() async throws {

    var appContainer = AppContainer.preview()
    appContainer.weatherService.updateForecastForCurrentLocation = { .init(name: "test") }

    let sut = WeatherViewModel(appContainer: appContainer)

    #expect(sut.status == .loading)

    await sut.notify(.load)

    #expect(sut.status == .loaded(.init(location: "test", forecast: [])))
  }

  @Test
  func Given_WeatherViewModel_When_LoadIsNotified_Then_DataLoadedMatch() async throws {

    let testDate = Date(timeIntervalSince1970: 0)
    let weather = OpenMeteoWeatherCode.clearSky

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short

    let date = dateFormatter.string(from: testDate)
    let time = timeFormatter.string(from: testDate)

    let temperatureRaw = 10.0
    let temperatureUnit = "C"

    let temperatureFormatter = MeasurementFormatter()
    let temperature = temperatureFormatter.string(from: .init(value: temperatureRaw, unit: .init(symbol: temperatureUnit)))

    let location = "test"

    let stack = CoreDataStack(name: "Weather", readOnly: true)
    let userDefault = ThreadSafe([String: Any]())

    var appContainer = AppContainer.preview()
    appContainer.userDefaults = .init(
      get: { key in userDefault.wrappedValue[key] },
      set: { key, value in  userDefault.projectedValue.perform { $0[key] = value } }
    )
    appContainer.weatherService.updateForecastForCurrentLocation = { .init(name: location) }
    appContainer.persistenceContainer = { stack.persistentContainer }

    let context = appContainer.viewContext
    let forecast = Forecast(context: context)
    forecast.date = testDate
    forecast.temperature = temperatureRaw
    forecast.temperatureUnit = temperatureUnit
    forecast.location = location
    forecast.weatherService = .openMeteo
    forecast.openMeteoWeather = weather
    try? context.save()

    let sut = WeatherViewModel(appContainer: appContainer)

    #expect(sut.status == .loading)

    await sut.notify(.load)

    #expect(
      sut.status == .loaded(
        .init(
          location: location,
          forecast: [
            .init(
              date: date,
              time: time,
              temperature: temperature,
              weather: weather.description,
              sfSymbol: weather.sfSymbol
            )
          ]
        )
      )
    )
  }
}
