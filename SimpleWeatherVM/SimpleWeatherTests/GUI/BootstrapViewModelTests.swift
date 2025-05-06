import Testing
import SwiftUIApp
import SwiftUITestSupport
@testable import SimpleWeather

extension CoreDataSuite {

  @MainActor
  struct BootstrapViewModelTests { }
}

extension CoreDataSuite.BootstrapViewModelTests {

  @Test
  func Given_BootstrapViewModel_When_Created_Then_DefaultValuesAreValid() async throws {
    let sut = BootstrapViewModel()
    #expect(sut.isOnboardingCompleted == false)
    #expect({ switch sut.currentFeature { case .loading: return true; default: return false }}(), "Invalid Feature State")
  }

  @Test
  func Given_BootstrapViewModel_When_Bootstrapped_Then_GoesToOnboarding() async throws {
    let sut = BootstrapViewModel()
    await sut.notify(.bootstrap)
    #expect({ switch sut.currentFeature { case .onboarding: return true; default: return false }}(), "Invalid Feature State")
  }

  @Test
  func Given_BootstrapViewModel_When_BootstrappedAfterOnboarding_Then_GoesToWeather() async throws {
    let sut = BootstrapViewModel()
    await sut.notify(.bootstrap)
    await sut.notify(.onboardingCompleted)
    #expect(sut.isOnboardingCompleted == true)
    #expect({ switch sut.currentFeature { case .weather: return true; default: return false }}(), "Invalid Feature State")
  }
}
