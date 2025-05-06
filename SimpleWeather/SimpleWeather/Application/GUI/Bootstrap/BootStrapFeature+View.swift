import SwiftUIApp

extension BootstrapFeature: View {
  
  func body(with bag: CancellationBag) -> some View {
    Group {
      switch self.currentFeature {
      case .loading:
        ProgressView()

      case let .onboarding(container):
        OnboardingFeature(completion: { self.notify(.onboardingCompleted, storeIn: bag) })
          .environment(container)

      case let .weather(container):
        WeatherFeature()
          .environment(container)
      }
    }
    .task { await self.notify(.bootstrap) }
  }
}

#Preview {
  BootstrapFeature(loadAppContainer: { .preview() })
}
