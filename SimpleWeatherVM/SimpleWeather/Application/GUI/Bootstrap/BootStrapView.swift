import SwiftUIApp

struct BootstrapView: View {

  @StateObject
  private var viewModel = BootstrapViewModel()

  @StateObject
  private var bag = CancellationBag()

  var body: some View {
    Group {
      switch self.viewModel.currentFeature {
      case .loading:
        ProgressView()
          .task { await self.viewModel.notify(.bootstrap) }

      case let .onboarding(appContainer):
        OnboardingView(
          container: appContainer,
          completion: { self.viewModel.notify(.onboardingCompleted, storeIn: self.bag) }
        )

      case let .weather(appContainer):
        WeatherView(container: appContainer)
      }
    }
    .task { await self.viewModel.notify(.bootstrap) }
  }
}

#Preview {
  BootstrapView()
}
