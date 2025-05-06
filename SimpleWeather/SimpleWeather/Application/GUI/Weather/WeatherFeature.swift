import SwiftUIApp

struct WeatherFeature: ViewFeature {

  struct WeatherModel: Equatable {

    struct Forecast: Equatable {
      let date: String
      let time: String
      let temperature: String
      let weather: String
      let sfSymbol: String
    }

    let location: String
    let forecast: [Forecast]
  }

  enum Status: Equatable {
    case loading
    case loaded(WeatherModel)
  }

  @AppStorage(Constant.latestKnownForecastLocationKey)
  private var latestForecastLocation: String?

  @Environment(\.appContainer.weatherService.updateForecastForCurrentLocation)
  private var updateForecast

  @FetchRequest(sortDescriptors: [SortDescriptor(\Forecast.date, order: .forward)])
  private var forecast

  var forecastDidChange: Int { Array(self.forecast).hashValue }

  @State
  private(set) var status: Status = .loading
}

extension WeatherFeature {

  enum UIEvent {
    case load
    case forecastDidChange
  }

  func notify(_ event: UIEvent) async {
    switch event {
    case .load:
      do {
        // Filter Data with latest available Location if available
        if let latestLocation = self.latestForecastLocation {
          self.forecast.nsPredicate = NSPredicate(format: "location == %@", latestLocation)
        }

        self.status = await self.forecast.weatherStatus(for: self.latestForecastLocation ?? "Unknown Location")

        // Update The Forecast
        let location = try await self.updateForecast()

        // Update the predicate and trigger a UI onChange via forecastDidChange
        self.latestForecastLocation = location.name
        self.forecast.nsPredicate = NSPredicate(format: "location == %@", location.name)
        self.status = await self.forecast.weatherStatus(for: self.latestForecastLocation ?? "Unknown Location")

      } catch {
        // TODO: Handle Error
        print("\(error)")
      }
    case .forecastDidChange:
      self.status = await self.forecast.weatherStatus(for: self.latestForecastLocation ?? "Unknown Location")
    }
  }
}

private extension FetchedResults<Forecast> {

  func weatherStatus(for location: String) async -> WeatherFeature.Status {

    guard !self.isEmpty else { return .loaded(.init(location: location, forecast: [])) }

    let dayComponentFormatter = DateComponentsFormatter()
    dayComponentFormatter.allowedUnits = .day

    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none

    let timeFormatter = DateFormatter()
    timeFormatter.dateStyle = .none
    timeFormatter.timeStyle = .short

    let tFormatter = MeasurementFormatter()

    let formattedForecast: [WeatherFeature.WeatherModel.Forecast] = self.compactMap { cdForecast in

      guard let timeDate = cdForecast.date else { return nil }

      let timeDay = Calendar.current.component(.day, from: timeDate)
      let nowDay = Calendar.current.component(.day, from: .now)

      let isToday = timeDay == nowDay

      let weatherRepresentation = cdForecast.weatherRepresentation

      return .init(
        date: isToday ? "Today" : dateFormatter.string(from: timeDate),
        time: timeFormatter.string(from: timeDate),
        temperature: tFormatter.string(
          from: .init(value: cdForecast.temperature, unit: .init(symbol: cdForecast.temperatureUnit ?? "Cº"))
        ),
        weather: weatherRepresentation.description,
        sfSymbol: weatherRepresentation.sfSymbol
      )
    }

    return .loaded(.init(location: location, forecast: formattedForecast))
  }
}
