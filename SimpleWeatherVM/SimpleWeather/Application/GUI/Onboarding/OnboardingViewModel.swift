import SwiftUIApp

final class OnboardingViewModel: ViewModelFeature, ObservableObject {

  enum Page: Int8, CaseIterable {
    case welcome
    case location
    case finish
  }

  private let appContainer: AppContainer
  private let completion: () -> Void

  private var locationService: LocationService {
    self.appContainer.locationService
  }

  private var openURL: OpenURLService {
    self.appContainer.openURL
  }

  @Published
  private(set) var currentPage: Page = .welcome {
    didSet {
      self.currentPageDidChange = UUID()
    }
  }

  @Published
  private(set) var currentPageDidChange = UUID()

  var doneButtonDisabled: Bool {
    self.locationService.currentAuthorization() != .granted
  }

  init(appContainer: AppContainer, completion: @escaping () -> Void) {
    self.appContainer = appContainer
    self.completion = completion
  }
}

extension OnboardingViewModel {

  enum UIEvent {
    case nextToLocationPressed
    case locationButtonPressed
    case doneButtonPressed
    case dragDidEnd(onPage: Page)
  }

  func notify(_ event: UIEvent) async {
    switch event {
    case .nextToLocationPressed:
      self.currentPage = .location

    case .locationButtonPressed:
      do {
        try await self.locationService.requestAuthorization()
        self.currentPage = .finish
      } catch {
        // TODO: Error Handling
        self.openURL(URL(string: UIApplication.openSettingsURLString)!)
      }

    case .doneButtonPressed:
      self.completion()

    case let .dragDidEnd(page):
      self.currentPage = page
    }
  }
}
