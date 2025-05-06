import SwiftUIApp
import CoreLocationUI

struct OnboardingView: View {

  @StateObject
  private var viewModel: OnboardingViewModel

  @StateObject
  private var bag = CancellationBag()

  init(container: AppContainer, completion: @escaping () -> Void) {
    self._viewModel = StateObject(wrappedValue: OnboardingViewModel(appContainer: container, completion: completion))
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollViewReader { scroll in
        ScrollView([.horizontal], showsIndicators: false) {
          HStack(spacing: 0) {
            self.pageWelcome()
              .frame(width: geometry.size.width, height: geometry.size.height)
            self.pageLocation()
              .frame(width: geometry.size.width, height: geometry.size.height)
            self.pageFinish()
              .frame(width: geometry.size.width, height: geometry.size.height)
          }
          .frame(width: 3 * geometry.size.width, height: geometry.size.height)
        }
        .simultaneousGesture(self.dragGesture(with: geometry))
        .onChange(of: self.viewModel.currentPageDidChange) { _ in
          withAnimation { scroll.scrollTo(self.viewModel.currentPage) }
        }
      }
    }
  }
}

private extension OnboardingView {

  @ViewBuilder
  func pageWelcome() -> some View {
    VStack {
      Image(.sunRainFill)
        .symbolRenderingMode(.multicolor)
        .resizable()
        .animation(.bouncy)
        .aspectRatio(contentMode: .fit)
        .frame(width: 250)
        .padding(.vertical)
      Text("Welcome to SimpleWeather")
        .font(.title2).bold()
        .padding(.vertical)
      Text("This sample app will retrieve and present you the latest forecast for the next 7 days.")
        .padding(.vertical)
      Text("It showcase how to simply build the App using SwiftUIApp enabling SwiftUI to be Unit Tests with no changes in your code syntax.")
        .padding(.vertical)
      Text("No need to learn a new Architecture or SDK in order to build a more scalable application.")
        .padding(.vertical)
      Spacer()
      Button {
        self.viewModel.notify(.nextToLocationPressed, storeIn: self.bag)
      } label: {
        Text("Next")
          .padding()
          .frame(maxWidth: .infinity)
      }
      .tint(.white)
      .background { Color.blue }
      .clipShape(.capsule)
    }
    .padding()
    .id(OnboardingViewModel.Page.welcome)
  }

  @ViewBuilder
  func pageLocation() -> some View {
    VStack {
      Image(systemName: "location.circle")
        .symbolRenderingMode(.multicolor)
        .resizable()
        .animation(.bouncy)
        .aspectRatio(contentMode: .fit)
        .frame(width: 250)
        .padding(.vertical)
      Text("Enable Location Services")
        .font(.title2).bold()
        .padding(.vertical)
      Text("Your location is needed to retreve the Weather Forecast for the next 7 days")
        .padding(.vertical)
      Spacer()
      Button {
        self.viewModel.notify(.locationButtonPressed, storeIn: self.bag)
      } label: {
        Label("Request Authorization", systemImage: "location.fill")
          .padding()
          .frame(maxWidth: .infinity)
      }
      .tint(.white)
      .background { Color.blue }
      .clipShape(.capsule)
    }
    .padding()
    .id(OnboardingViewModel.Page.location)
  }

  @ViewBuilder
  func pageFinish() -> some View {
    VStack {
      Image(.sunMaxFill)
        .symbolRenderingMode(.multicolor)
        .resizable()
        .animation(.bouncy)
        .aspectRatio(contentMode: .fit)
        .frame(width: 250)
        .padding(.vertical)
      Spacer()
        .frame(height: 100)
      Text("Enjoy your weather")
        .font(.title2).bold()
        .padding(.vertical)
      Text("Tap done to start")
        .padding(.vertical)
      Spacer()
      Button {
        self.viewModel.notify(.doneButtonPressed, storeIn: self.bag)
      } label: {
        Text("Done")
          .padding()
          .frame(maxWidth: .infinity)
      }
      .disabled(self.viewModel.doneButtonDisabled)
      .tint(.white)
      .background { Color.blue }
      .clipShape(.capsule)
    }
    .padding()
    .id(OnboardingViewModel.Page.finish)
  }

  // Since iOS 15 does not allow disabling the Gesture
  // Then we Intercept and animate the changes going to the next page.
  func dragGesture(with geometry: GeometryProxy) -> some Gesture {
    DragGesture()
      .onEnded { value in
        let threshold = geometry.size.width / 2
        var nextPage = self.viewModel.currentPage
        if value.predictedEndTranslation.width > threshold {
          nextPage = OnboardingViewModel.Page(rawValue: max(0, self.viewModel.currentPage.rawValue - 1))!
        } else if value.predictedEndTranslation.width < -threshold {
          nextPage = OnboardingViewModel.Page(
            rawValue: min(
              Int8(OnboardingViewModel.Page.allCases.count) - 1,
              self.viewModel.currentPage.rawValue + 1
            )
          )!
        }
        self.viewModel.notify(.dragDidEnd(onPage: nextPage), storeIn: self.bag)
      }
  }
}

#Preview("Scrollable Onboarding") {
  OnboardingView(container: .preview(), completion: {})
}

#Preview("Page One") {
  OnboardingView(container: .preview(), completion: {})
    .pageWelcome()
}

#Preview("Page Two") {
  OnboardingView(container: .preview(), completion: {})
    .pageLocation()
}

#Preview("Page Three") {
  OnboardingView(container: .preview(), completion: {})
    .pageFinish()
}
