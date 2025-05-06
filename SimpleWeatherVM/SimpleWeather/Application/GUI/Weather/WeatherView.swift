import SwiftUIApp

struct WeatherView: View {

  @StateObject
  private var viewModel: WeatherViewModel

  @StateObject
  private var bag = CancellationBag()

  init(container: AppContainer) {
    self._viewModel = StateObject(wrappedValue: WeatherViewModel(appContainer: container))
  }

  var body: some View {
    Group {
      switch self.viewModel.status {
      case let .loaded(data):
        VStack {
          self.forecastCarouselHeader(with: data)
          self.forecastCarousel(with: data)
          Spacer()
        }

      case .loading:
        ProgressView()
      }
    }
    .task { await self.viewModel.notify(.load) }
  }
}

extension WeatherView {

  @ViewBuilder
  func forecastCarouselHeader(with model: WeatherViewModel.WeatherModel) -> some View {
    HStack {
      Spacer()
      Text(model.location)
      Spacer()
    }
  }

  @ViewBuilder
  func forecastCarousel(with model: WeatherViewModel.WeatherModel) -> some View {
    ScrollView([.horizontal], showsIndicators: false) {
      LazyHGrid(rows: [GridItem()], alignment: .top) {
        ForEach(0 ..< model.forecast.count, id: \.self) { index in
          self.forecastCell(forecast: model.forecast[index])
        }
      }
      .padding()
    }
  }

  @ViewBuilder
  func forecastCell(forecast: WeatherViewModel.WeatherModel.Forecast) -> some View {
    VStack(spacing: 8) {
      Text(forecast.date)
      VStack(spacing: 12) {
        Text(forecast.time)
        Text(forecast.temperature)
        Text(forecast.weather)
          .font(.body).bold()
          .multilineTextAlignment(.center)
        Image(systemName: forecast.sfSymbol)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 35)
      }
      .padding()
      .frame(width: 200)
      .background { Color.cyan }
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .shadow(radius: 3)
    }
  }
}

#Preview("Weather View") {
  WeatherView(container: .preview())
}

struct ForecastCellPreview: PreviewProvider {

  static var previews: some View {
    ForEach(OpenMeteoWeatherCode.allCases, id: \.self) { weather in
      WeatherView(container: .preview())
        .forecastCell(
          forecast: .init(
            date: "Date",
            time: "Time",
            temperature: "10",
            weather: weather.description,
            sfSymbol: weather.sfSymbol
          )
        )
        .previewDisplayName(weather.description)
    }
  }
}
