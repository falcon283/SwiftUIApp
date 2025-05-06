import CoreData
import SwiftUIApp
import SwiftAppUtilities

final class FetchedControlerDelegate: NSObject, NSFetchedResultsControllerDelegate {

  private let didUpdate: (NSFetchedResultsController<any NSFetchRequestResult>) -> Void

  init(didUpdate: @escaping (NSFetchedResultsController<any NSFetchRequestResult>) -> Void) {
    self.didUpdate = didUpdate
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
    self.didUpdate(controller)
  }
}

final class WeatherViewModel: ViewModelFeature, ObservableObject {

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

  private let appContainer: AppContainer
  private let fetchResultController: NSFetchedResultsController<Forecast>
  private var controllerDelegate: FetchedControlerDelegate?

  private var latestForecastLocation: String? {
    get {
      self.appContainer.userDefaults.getValue(for: Constant.latestKnownForecastLocationKey, defaultValue: nil)
    }
    set {
      self.appContainer.userDefaults.setValue(newValue, key: Constant.latestKnownForecastLocationKey)
    }
  }

  private var updateForecast: @Sendable () async throws -> WeatherServiceLocation {
    self.appContainer.weatherService.updateForecastForCurrentLocation
  }

  private var forecast: [Forecast] {
    self.fetchResultController.fetchedObjects ?? []
  }

  @Published
  private(set) var status: Status = .loading

  init(appContainer: AppContainer) {
    self.appContainer = appContainer

    let fetchRequest = Forecast.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

    self.fetchResultController = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: appContainer.persistenceContainer().viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil
    )

    self.controllerDelegate = FetchedControlerDelegate { [weak self] controller in
      Task { (await self?.getUpdatedStatus()).map { self?.status = $0 } }
    }

    self.fetchResultController.delegate = self.controllerDelegate
  }
}

extension WeatherViewModel {

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
          self.fetchResultController.fetchRequest.predicate = NSPredicate(format: "location == %@", latestLocation)
          try? self.fetchResultController.performFetch()
        }

        // Load initial status immediately.
        self.status = await self.getUpdatedStatus()

        // Update The Forecast
        let location = try await self.updateForecast()

        // Update the predicate and trigger a UI onChange via forecastDidChange
        self.latestForecastLocation = location.name
        self.fetchResultController.fetchRequest.predicate = NSPredicate(format: "location == %@", location.name)
        try? self.fetchResultController.performFetch()
        self.status = await getUpdatedStatus()

      } catch {
        // TODO: Handle Error
        print("\(error)")
      }
    case .forecastDidChange:
      self.status = await getUpdatedStatus()
    }
  }

  private func getUpdatedStatus() async -> Status {
    let safeForecastAfter = ThreadSafe(self.forecast)
    return await safeForecastAfter.wrappedValue.weatherStatus(for: self.latestForecastLocation ?? "Unknown Location")
  }
}

private extension Array where Element == Forecast {

  func weatherStatus(for location: String) async -> WeatherViewModel.Status {

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

    let formattedForecast: [WeatherViewModel.WeatherModel.Forecast] = self.compactMap { cdForecast in

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
