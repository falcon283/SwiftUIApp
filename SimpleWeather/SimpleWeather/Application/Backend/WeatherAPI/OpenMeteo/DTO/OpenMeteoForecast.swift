import Foundation

struct OpenMeteoForecastResult: Decodable {

  let latitude: Double
  let longitude: Double
  let elevation: Double
  let generationTimeMs: Double
  let utcOffsetSeconds: Int
  let timezone: String
  let timezoneAbbreviation: String
  let hourly: Hourly?
  let hourlyUnits: HourlyUnits?

  enum CodingKeys: String, CodingKey {
    case latitude
    case longitude
    case elevation
    case generationTimeMs = "generationtime_ms"
    case utcOffsetSeconds = "utc_offset_seconds"
    case timezone
    case timezoneAbbreviation = "timezone_abbreviation"
    case hourly
    case hourlyUnits = "hourly_units"
  }

  struct Hourly: Decodable {
    let time: [Int]
    let temperature2m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
      case time
      case temperature2m = "temperature_2m"
      case weatherCode = "weather_code"
    }
  }

  struct HourlyUnits: Decodable {
    let temperature2m: String

    enum CodingKeys: String, CodingKey {
      case temperature2m = "temperature_2m"
    }
  }
}

extension OpenMeteoForecastResult.Hourly {
  var weatherCodeEnum: [OpenMeteoWeatherCode] {
    self.weatherCode.map { code in
      OpenMeteoWeatherCode(rawValue: code) ?? .unknown
    }
  }
}

enum OpenMeteoWeatherCode: Int, CaseIterable {
  case clearSky = 0
  case mainlyClear = 1
  case partlyCloudy = 2
  case overcast = 3
  case fog = 45
  case depositingRimeFog = 48
  case drizzleLight = 51
  case drizzleModerate = 53
  case drizzleDense = 55
  case freezingDrizzleLight = 56
  case freezingDrizzleDense = 57
  case rainSlight = 61
  case rainModerate = 63
  case rainHeavy = 65
  case freezingRainLight = 66
  case freezingRainHeavy = 67
  case snowFallSlight = 71
  case snowFallModerate = 73
  case snowFallHeavy = 75
  case snowGrains = 77
  case rainShowersLight = 80
  case rainShowersModerate = 81
  case rainShowersViolent = 82
  case snowShowersLight = 85
  case snowShowersHeavy = 86
  case thunderstorm = 95
  case thunderstormWithSlightHail = 96
  case thunderstormWithHeavyHail = 99

  case unknown = 99999
}
