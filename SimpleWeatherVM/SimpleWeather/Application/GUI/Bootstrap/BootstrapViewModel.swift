import SwiftUIApp

final class BootstrapViewModel: ViewModelFeature, ObservableObject {

  enum CurrentFeature {
    case loading
    case onboarding(AppContainer)
    case weather(AppContainer)
  }

  @Published
  private(set) var isOnboardingCompleted: Bool = false {
    didSet {
      self.currentFeature.container?.userDefaults
        .setValue(self.isOnboardingCompleted, key: Constant.isOnboardingCompletedKey)
    }
  }

  @Published
  private(set) var currentFeature: CurrentFeature = .loading

  init() { }
}

extension BootstrapViewModel {

  enum UIEvent {
    case bootstrap
    case onboardingCompleted
  }

  func notify(_ event: UIEvent) async {
    switch event {
    case .bootstrap:
      await self.bootstrap()

    case .onboardingCompleted:
      switch self.currentFeature {
      case let .onboarding(container):
        self.isOnboardingCompleted = true
        self.currentFeature = .weather(container)

      case .loading, .weather:
        break
      }
    }
  }
}

private extension BootstrapViewModel {

  func bootstrap() async {
    let container = await AppContainer.live()

    self.isOnboardingCompleted = container.userDefaults
      .getValue(for: Constant.isOnboardingCompletedKey, defaultValue: false)

    if self.isOnboardingCompleted && container.locationService.currentAuthorization() == .granted {
      self.currentFeature = .weather(container)
    } else {
      self.currentFeature = .onboarding(container)
    }
  }
}

private extension BootstrapViewModel.CurrentFeature {

  var container: AppContainer? {
    switch self {
    case .loading:
      return nil

    case let .onboarding(appContainer),
         let .weather(appContainer):
      return appContainer
    }
  }
}
