import Foundation

// MARK: - Respuesta principal de Open-Meteo

struct WeatherResponse: Codable {
    let current: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature2m: Double
    let apparentTemperature: Double
    let relativeHumidity2m: Int
    let weatherCode: Int
    let windSpeed10m: Double
    let isDay: Int
    let uvIndex: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity2m = "relative_humidity_2m"
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
        case isDay = "is_day"
        case uvIndex = "uv_index"
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature2m: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

struct DailyWeather: Codable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let precipitationProbabilityMax: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case precipitationProbabilityMax = "precipitation_probability_max"
    }
}

// MARK: - Geocodificación (búsqueda de ciudades)

struct GeocodingResponse: Codable {
    let results: [GeoPlace]?
}

struct GeoPlace: Codable, Identifiable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let admin1: String?
    let country: String?
}

// MARK: - Lugar seleccionado en la app

struct Place {
    var name: String
    var admin1: String
    var country: String
    var latitude: Double
    var longitude: Double

    static let puenteAlto = Place(
        name: "Puente Alto",
        admin1: "Región Metropolitana",
        country: "Chile",
        latitude: -33.611,
        longitude: -70.576
    )
}

// MARK: - Traducción de códigos WMO

enum WeatherKind {
    case sun, cloud, rain, snow, storm, fog
}

func weatherKind(for code: Int) -> WeatherKind {
    switch code {
    case 0, 1: return .sun
    case 2, 3: return .cloud
    case 45, 48: return .fog
    case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82: return .rain
    case 71, 73, 75, 77, 85, 86: return .snow
    case 95, 96, 99: return .storm
    default: return .cloud
    }
}

let weatherLabels: [Int: String] = [
    0: "Cielo despejado", 1: "Mayormente despejado", 2: "Parcialmente nublado", 3: "Nublado",
    45: "Neblina", 48: "Neblina con escarcha",
    51: "Llovizna ligera", 53: "Llovizna", 55: "Llovizna intensa",
    56: "Llovizna helada", 57: "Llovizna helada intensa",
    61: "Lluvia ligera", 63: "Lluvia", 65: "Lluvia intensa",
    66: "Lluvia helada", 67: "Lluvia helada intensa",
    71: "Nieve ligera", 73: "Nieve", 75: "Nieve intensa", 77: "Granizo fino",
    80: "Chubascos ligeros", 81: "Chubascos", 82: "Chubascos intensos",
    85: "Chubascos de nieve", 86: "Chubascos de nieve intensos",
    95: "Tormenta eléctrica", 96: "Tormenta con granizo", 99: "Tormenta severa",
]
