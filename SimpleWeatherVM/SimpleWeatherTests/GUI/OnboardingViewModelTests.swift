import Testing
import SwiftUI
import SwiftUIApp
import SwiftUITestSupport
import SwiftAppUtilities
@testable import SimpleWeather

extension CoreDataSuite {

  @MainActor
  struct OnboardingViewModelTests { }
}

extension CoreDataSuite.OnboardingViewModelTests {

  @Test
  func Given_OnboardingViewModel_When_LocationIsNotGranted_Then_DoneButtonIsDisabled() async throws {

    var appContainer = AppContainer.preview()
    appContainer.locationService.currentAuthorization = { .unknown }
    appContainer.openURL = OpenURLService { _ in }

    let sut = OnboardingViewModel(appContainer: appContainer, completion: { })

    #expect(sut.currentPage == .welcome)
    #expect(sut.doneButtonDisabled == true)
  }

  @Test
  func Given_OnboardingViewModel_When_LocationIsGranted_Then_DoneButtonIsDisabled() async throws {

    var appContainer = AppContainer.preview()
    appContainer.locationService.currentAuthorization = { .granted }

    let sut = OnboardingViewModel(appContainer: appContainer, completion: { })

    #expect(sut.currentPage == .welcome)
    #expect(sut.doneButtonDisabled == false)
  }

  @Test
  func Given_OnboardingViewModel_When_NextToLocationIsNotified_Then_NextPageIsLocation() async throws {

    var appContainer = AppContainer.preview()
    appContainer.locationService.currentAuthorization = { .granted }

    let sut = OnboardingViewModel(appContainer: appContainer, completion: { })


    await sut.notify(.nextToLocationPressed)

    #expect(sut.currentPage == .location)
  }

  @Test
  func Given_OnboardingViewModel_When_LocationButtonPressed_Then_NextPageIsLocation() async throws {

    @ThreadSafe
    var requestAuthorizationCalled = false
    let cs = $requestAuthorizationCalled

    var appContainer = AppContainer.preview()
    appContainer.locationService.requestAuthorization = { cs.assign(true) }

    let sut = OnboardingViewModel(appContainer: appContainer, completion: { })

    await sut.notify(.locationButtonPressed)

    #expect(sut.currentPage == .finish)
    #expect(requestAuthorizationCalled == true)
  }

  @Test
  func Given_OnboardingViewModel_When_DoneButtonPressed_Then_CompletionIsCalled() async throws {

    var completionCalled = false
    let sut = OnboardingViewModel(appContainer: .preview(), completion: { completionCalled = true })

    await sut.notify(.doneButtonPressed)

    #expect(completionCalled == true)
  }

  @Test
  func Given_OnboardingViewModel_When_DragDidEnd_Then_CurrentPageIsUpdated() async throws {

    let sut = OnboardingViewModel(appContainer: .preview(), completion: { })

    #expect(sut.currentPage == .welcome)

    await sut.notify(.dragDidEnd(onPage: .location))

    #expect(sut.currentPage == .location)
  }
}
