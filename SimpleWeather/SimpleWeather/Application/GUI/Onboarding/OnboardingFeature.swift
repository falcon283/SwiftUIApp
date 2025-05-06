import SwiftUIApp

struct OnboardingFeature: ViewFeature {

  enum Page: Int8, CaseIterable {
    case welcome
    case location
    case finish
  }

  private let completion: () -> Void

  @Environment(\.appContainer.locationService)
  private var locationService

  @Environment(\.openURL)
  private var openURL

  @State
  private(set) var currentPage: Page = .welcome {
    didSet {
      self.currentPageDidChange = UUID()
    }
  }

  @State
  private(set) var currentPageDidChange = UUID()

  var doneButtonDisabled: Bool {
    self.locationService.currentAuthorization() != .granted
  }

  init(completion: @escaping () -> Void) {
    self.completion = completion
  }
}

extension OnboardingFeature {

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
