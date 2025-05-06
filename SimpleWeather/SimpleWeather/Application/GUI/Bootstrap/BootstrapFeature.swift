import SwiftUIApp

struct BootstrapFeature: ViewFeature {

  enum CurrentFeature {
    case loading
    case onboarding(container: AppContainer)
    case weather(container: AppContainer)
  }


  @AppStorage(wrappedValue: false, Constant.isOnboardingCompletedKey)
  private(set) var isOnboardingCompleted

  @State
  private(set) var currentFeature: CurrentFeature = .loading

  private let loadAppContainer: () async -> AppContainer

  init(loadAppContainer: @escaping () async -> AppContainer) {
    self.loadAppContainer = loadAppContainer
  }
}

extension BootstrapFeature {

  enum UIEvent {
    case bootstrap
    case onboardingCompleted
  }

  func notify(_ event: UIEvent) async {
    switch event {
    case .bootstrap:
      await self.selectNeededFeature(with: self.loadAppContainer())

    case .onboardingCompleted:
      switch self.currentFeature {
      case let .onboarding(container):
        self.isOnboardingCompleted = true
        self.currentFeature = .weather(container: container)

      case .loading, .weather:
        break
      }
    }
  }
}

private extension BootstrapFeature {

  func selectNeededFeature(with container: AppContainer) async {
    if self.isOnboardingCompleted && container.locationService.currentAuthorization() == .granted {
      self.currentFeature = .weather(container: container)
    } else {
      self.currentFeature = .onboarding(container: container)
    }
  }
}
