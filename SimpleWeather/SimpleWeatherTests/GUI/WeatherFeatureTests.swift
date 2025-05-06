import Foundation
import Testing
import SwiftUIApp
import SwiftUITestSupport
@testable import SimpleWeather

extension CoreDataSuite {

  @MainActor
  struct WeatherFeatureTests { }
}

extension CoreDataSuite.WeatherFeatureTests {

  @Test
  func Given_WeatherFeature_When_Created_Then_IsInLoadingStatus() async throws {

    try await given(WeatherFeature()) { injector in
      try await injector
        .environment(\.appContainer.weatherService.updateForecastForCurrentLocation, { .init(name: "test") })
        .startCoreData(named: "Weather", bundle: .main)
    } expect: { sut in
      #expect(sut.status == .loading)
    }
  }

  @Test
  func Given_WeatherFeature_When_LoadIsNotifiedButEmptyForecast_Then_DataLoadedMatch() async throws {

    try await given(WeatherFeature()) { injector in
      try await injector
        .environment(\.appContainer.weatherService.updateForecastForCurrentLocation, { .init(name: "test") })
        .startCoreData(named: "Weather", bundle: .main)
    } expect: { sut in
      #expect(sut.status == .loading)

      await sut.notify(.load)

      #expect(sut.status == .loaded(.init(location: "test", forecast: [])))
    }
  }

  @Test
  func Given_WeatherFeature_When_LoadIsNotified_Then_DataLoadedMatch() async throws {

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

    try await given(WeatherFeature()) { injector in
      try await injector
        .environment(\.appContainer.weatherService.updateForecastForCurrentLocation, { .init(name: location) })
        .startCoreData(named: "Weather", bundle: .main)
        .insert(Forecast.self) { forecast in
          forecast.date = testDate
          forecast.temperature = temperatureRaw
          forecast.temperatureUnit = temperatureUnit
          forecast.location = location
          forecast.weatherService = .openMeteo
          forecast.openMeteoWeather = weather
        }
    } expect: { sut in
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
}
