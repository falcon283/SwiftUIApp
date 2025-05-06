import Testing
import SwiftUI
import SwiftUIApp
import SwiftUITestSupport
import SwiftAppUtilities
@testable import SimpleWeather

extension CoreDataSuite {

  @MainActor
  struct OnboardingFeatureTests { }
}

extension CoreDataSuite.OnboardingFeatureTests {

  @Test
  func Given_OnboardingFeature_When_LocationIsNotGranted_Then_DoneButtonIsDisabled() async throws {

    var locationService = AppContainer.preview().locationService
    locationService.currentAuthorization = { .unknown }

    try await given(OnboardingFeature(completion: { })) {
      $0.environment(\.appContainer.locationService, locationService)
        .environment(\.openURL, OpenURLAction { _ in .handled })
    } expect: { sut in
      #expect(sut.currentPage == .welcome)
      #expect(sut.doneButtonDisabled == true)
    }
  }

  @Test
  func Given_OnboardingFeature_When_LocationIsGranted_Then_DoneButtonIsDisabled() async throws {

    var locationService = AppContainer.preview().locationService
    locationService.currentAuthorization = { .granted }

    try await given(OnboardingFeature(completion: { })) {
      $0.environment(\.appContainer.locationService, locationService)
    } expect: { sut in
      #expect(sut.currentPage == .welcome)
      #expect(sut.doneButtonDisabled == false)
    }
  }

  @Test
  func Given_OnboardingFeature_When_NextToLocationIsNotified_Then_NextPageIsLocation() async throws {

    var locationService = AppContainer.preview().locationService
    locationService.currentAuthorization = { .granted }

    try await given(OnboardingFeature(completion: { })) {
      $0.environment(\.appContainer.locationService, locationService)
    } expect: { sut in

      await sut.notify(.nextToLocationPressed)

      #expect(sut.currentPage == .location)
    }
  }

  @Test
  func Given_OnboardingFeature_When_LocationButtonPressed_Then_NextPageIsLocation() async throws {

    @ThreadSafe
    var requestAuthorizationCalled = false
    let cs = $requestAuthorizationCalled

    var locationService = AppContainer.preview().locationService
    locationService.requestAuthorization = { cs.assign(true) }

    try await given(OnboardingFeature(completion: { })) {
      $0.environment(\.appContainer.locationService, locationService)
    } expect: { sut in

      await sut.notify(.locationButtonPressed)

      #expect(sut.currentPage == .finish)
      #expect(requestAuthorizationCalled == true)
    }
  }

  @Test
  func Given_OnboardingFeature_When_DoneButtonPressed_Then_CompletionIsCalled() async throws {

    let locationService = AppContainer.preview().locationService

    var completionCalled = false
    try await given(OnboardingFeature(completion: { completionCalled = true })) {
      $0.environment(\.appContainer.locationService, locationService)
    } expect: { sut in

      await sut.notify(.doneButtonPressed)

      #expect(completionCalled == true)
    }
  }

  @Test
  func Given_OnboardingFeature_When_DragDidEnd_Then_CurrentPageIsUpdated() async throws {

    let locationService = AppContainer.preview().locationService

    try await given(OnboardingFeature(completion: { })) {
      $0.environment(\.appContainer.locationService, locationService)
    } expect: { sut in

      #expect(sut.currentPage == .welcome)

      await sut.notify(.dragDidEnd(onPage: .location))

      #expect(sut.currentPage == .location)
    }
  }
}
