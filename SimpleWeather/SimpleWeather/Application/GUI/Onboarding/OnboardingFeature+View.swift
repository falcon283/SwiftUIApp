import SwiftUIApp
import CoreLocationUI

extension OnboardingFeature: View {

  func body(with bag: CancellationBag) -> some View {
    GeometryReader { geometry in
      ScrollViewReader { scroll in
        ScrollView([.horizontal], showsIndicators: false) {
          HStack(spacing: 0) {
            self.pageWelcome(with: bag)
              .frame(width: geometry.size.width, height: geometry.size.height)
            self.pageLocation(with: bag)
              .frame(width: geometry.size.width, height: geometry.size.height)
            self.pageFinish(with: bag)
              .frame(width: geometry.size.width, height: geometry.size.height)
          }
          .frame(width: 3 * geometry.size.width, height: geometry.size.height)
        }
        .simultaneousGesture(self.dragGesture(with: geometry, bag: bag))
        .onChange(of: self.currentPageDidChange) { _ in
          withAnimation { scroll.scrollTo(self.currentPage) }
        }
      }
    }
  }
}

private extension OnboardingFeature {

  @ViewBuilder
  func pageWelcome(with bag: CancellationBag) -> some View {
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
        self.notify(.nextToLocationPressed, storeIn: bag)
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
    .id(Page.welcome)
  }

  @ViewBuilder
  func pageLocation(with bag: CancellationBag) -> some View {
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
        self.notify(.locationButtonPressed, storeIn: bag)
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
    .id(Page.location)
  }

  @ViewBuilder
  func pageFinish(with bag: CancellationBag) -> some View {
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
        self.notify(.doneButtonPressed, storeIn: bag)
      } label: {
        Text("Done")
          .padding()
          .frame(maxWidth: .infinity)
      }
      .disabled(self.doneButtonDisabled)
      .tint(.white)
      .background { Color.blue }
      .clipShape(.capsule)
    }
    .padding()
    .id(Page.finish)
  }

  // Since iOS 15 does not allow disabling the Gesture
  // Then we Intercept and animate the changes going to the next page.
  func dragGesture(with geometry: GeometryProxy, bag: CancellationBag) -> some Gesture {
    DragGesture()
      .onEnded { value in
        let threshold = geometry.size.width / 2
        var nextPage = self.currentPage
        if value.predictedEndTranslation.width > threshold {
          nextPage = Page(rawValue: max(0, self.currentPage.rawValue - 1))!
        } else if value.predictedEndTranslation.width < -threshold {
          nextPage = Page(rawValue: min(Int8(Page.allCases.count) - 1, self.currentPage.rawValue + 1))!
        }
        self.notify(.dragDidEnd(onPage: nextPage), storeIn: bag)
      }
  }
}

#Preview("Scrollable Onboarding") {
  OnboardingFeature(completion: {})
}

#Preview("Page One") {
  OnboardingFeature(completion: {})
    .pageWelcome(with: CancellationBag())
}

#Preview("Page Two") {
  OnboardingFeature(completion: {})
    .pageLocation(with: CancellationBag())
}

#Preview("Page Three") {
  OnboardingFeature(completion: {})
    .pageFinish(with: CancellationBag())
}
