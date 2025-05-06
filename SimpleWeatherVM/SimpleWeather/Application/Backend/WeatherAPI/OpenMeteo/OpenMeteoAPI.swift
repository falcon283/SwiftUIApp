import Foundation

struct GetWeatherPayload: Encodable {

  let latitude: Double
  let longitude: Double
  let hourly = "temperature_2m,weather_code"
  let timeformat = "unixtime"
}

enum OpenMeteoAPI {
  static let getOpenMeteoForecastRequest = HTTPRequest<GetWeatherPayload, OpenMeteoForecastResult>(
    baseURL: "https://api.open-meteo.com",
    path: "/v1/forecast"
  )
}
