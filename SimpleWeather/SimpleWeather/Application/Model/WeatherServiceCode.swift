import Foundation

enum WeatherServiceCode: Int64 {
  case openMeteo = 0
}

extension Forecast {
  var weatherService: WeatherServiceCode {
    get { WeatherServiceCode(rawValue: self.serviceRawValue) ?? .openMeteo }
    set { self.serviceRawValue = newValue.rawValue }
  }

  var openMeteoWeather: OpenMeteoWeatherCode {
    get { OpenMeteoWeatherCode(rawValue: Int(self.weatherRawValue)) ?? .unknown }
    set { self.weatherRawValue = Int64(newValue.rawValue) }
  }
}
