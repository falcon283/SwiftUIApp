import SwiftUIApp

@main
struct SimpleWeatherApp: App {
  var body: some Scene {
    WindowGroup {
      if ProcessInfo.isRunningUnitTests {
        EmptyView()
      } else {
        BootstrapFeature(loadAppContainer: { await .live() })
      }
    }
  }
}
