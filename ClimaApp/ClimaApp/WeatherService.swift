import Foundation

enum WeatherServiceError: Error {
    case badURL
    case badResponse
}

struct WeatherService {

    static func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        var comps = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        comps.queryItems = [
            .init(name: "latitude", value: "\(latitude)"),
            .init(name: "longitude", value: "\(longitude)"),
            .init(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day,uv_index"),
            .init(name: "hourly", value: "temperature_2m,weather_code"),
            .init(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
            .init(name: "timezone", value: "auto"),
            .init(name: "forecast_days", value: "7"),
        ]
        guard let url = comps.url else { throw WeatherServiceError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw WeatherServiceError.badResponse
        }
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }

    static func searchCity(_ query: String) async throws -> [GeoPlace] {
        var comps = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        comps.queryItems = [
            .init(name: "name", value: query),
            .init(name: "count", value: "6"),
            .init(name: "language", value: "es"),
            .init(name: "format", value: "json"),
        ]
        guard let url = comps.url else { throw WeatherServiceError.badURL }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw WeatherServiceError.badResponse
        }
        let decoded = try JSONDecoder().decode(GeocodingResponse.self, from: data)
        return decoded.results ?? []
    }
}
