import SwiftUI

enum LoadStatus {
    case loading, ready, error
}

struct ContentView: View {
    @State private var place = Place.puenteAlto
    @State private var weather: WeatherResponse?
    @State private var status: LoadStatus = .loading
    @State private var query = ""
    @State private var results: [GeoPlace] = []
    @State private var useFahrenheit = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        searchBar

                        switch status {
                        case .loading:
                            ProgressView("Cargando el clima…")
                                .tint(currentScene.text)
                                .foregroundStyle(currentScene.text)
                                .padding(.top, 120)
                        case .error:
                            VStack(spacing: 10) {
                                Text("No se pudo obtener el clima.")
                                Button("Reintentar") { Task { await load() } }
                                    .buttonStyle(.borderedProminent)
                            }
                            .foregroundStyle(currentScene.text)
                            .padding(.top, 100)
                        case .ready:
                            if let weather {
                                header(weather)
                                hourlyStrip(weather)
                                dailyList(weather)
                                detailGrid(weather)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .task { await load() }
        .onChange(of: locationManager.coordinate) { _, coord in
            guard let coord else { return }
            place = Place(name: "Mi ubicación", admin1: "", country: "", latitude: coord.latitude, longitude: coord.longitude)
            Task { await load() }
        }
        .onChange(of: query) { _, newValue in
            Task { await search(newValue) }
        }
    }

    // MARK: - Datos

    private var currentScene: WeatherScene {
        guard let cur = weather?.current else {
            return scene(for: 0, isDay: true)
        }
        return scene(for: cur.weatherCode, isDay: cur.isDay == 1)
    }

    private var background: some View {
        LinearGradient(colors: currentScene.sky, startPoint: .topLeading, endPoint: .bottomTrailing)
            .animation(.easeInOut(duration: 0.9), value: currentScene.sky)
    }

    private func load() async {
        status = .loading
        do {
            weather = try await WeatherService.fetchWeather(latitude: place.latitude, longitude: place.longitude)
            status = .ready
        } catch {
            status = .error
        }
    }

    private func search(_ text: String) async {
        guard text.count >= 2 else { results = []; return }
        do {
            results = try await WeatherService.searchCity(text)
        } catch {
            results = []
        }
    }

    private func pick(_ r: GeoPlace) {
        place = Place(name: r.name, admin1: r.admin1 ?? "", country: r.country ?? "", latitude: r.latitude, longitude: r.longitude)
        query = ""
        results = []
        Task { await load() }
    }

    private func toUnit(_ celsius: Double) -> Int {
        useFahrenheit ? Int((celsius * 9 / 5 + 32).rounded()) : Int(celsius.rounded())
    }

    private var unitSuffix: String { useFahrenheit ? "°F" : "°" }

    // MARK: - Secciones

    private var searchBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(currentScene.text.opacity(0.85))
                TextField("Buscar ciudad", text: $query)
                    .foregroundStyle(currentScene.text)
                    .autocorrectionDisabled()
                Button {
                    locationManager.request()
                } label: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(currentScene.text)
                        .padding(6)
                        .background(.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if !results.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(results) { r in
                        Button { pick(r) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.name).font(.subheadline).fontWeight(.semibold)
                                Text([r.admin1, r.country].compactMap { $0 }.joined(separator: ", "))
                                    .font(.caption).opacity(0.7)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14).padding(.vertical, 10)
                        }
                        Divider().opacity(0.2)
                    }
                }
                .foregroundStyle(.white)
                .background(.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private func header(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 4) {
            Text(place.name).font(.title2).fontWeight(.semibold)
            Text([place.admin1, place.country].filter { !$0.isEmpty }.joined(separator: " · "))
                .font(.caption).opacity(0.75)

            WeatherGlyph(kind: weatherKind(for: weather.current.weatherCode), size: 120, accent: currentScene.accent)
                .padding(.vertical, 4)

            Text("\(toUnit(weather.current.temperature2m))\(unitSuffix)")
                .font(.system(size: 80, weight: .thin))

            Text(weatherLabels[weather.current.weatherCode] ?? "—")
                .font(.headline)

            Text("Sensación \(toUnit(weather.current.apparentTemperature))\(unitSuffix)")
                .font(.caption).opacity(0.8)

            Button(useFahrenheit ? "Cambiar a °C" : "Cambiar a °F") {
                useFahrenheit.toggle()
            }
            .font(.caption)
            .padding(.horizontal, 14).padding(.vertical, 5)
            .background(.white.opacity(0.18))
            .clipShape(Capsule())
            .padding(.top, 4)
        }
        .foregroundStyle(currentScene.text)
        .padding(.horizontal, 20)
    }

    private func hourlyStrip(_ weather: WeatherResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRÓXIMAS HORAS").font(.caption2).opacity(0.75).padding(.horizontal, 14)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(nextHours(weather).enumerated()), id: \.offset) { i, h in
                        VStack(spacing: 6) {
                            Text(i == 0 ? "Ahora" : hourLabel(h.time)).font(.caption)
                            WeatherGlyph(kind: weatherKind(for: h.code), size: 26, accent: currentScene.accent)
                            Text("\(toUnit(h.temp))°").font(.subheadline).fontWeight(.semibold)
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 4)
            }
        }
        .padding(.vertical, 12)
        .foregroundStyle(currentScene.text)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private func dailyList(_ weather: WeatherResponse) -> some View {
        let mins = weather.daily.temperature2mMin
        let maxs = weather.daily.temperature2mMax
        let rangeMin = mins.min() ?? 0
        let rangeMax = maxs.max() ?? 1

        return VStack(alignment: .leading, spacing: 0) {
            Text("7 DÍAS").font(.caption2).opacity(0.75).padding(.bottom, 6)
            ForEach(Array(weather.daily.time.enumerated()), id: \.offset) { i, t in
                let minT = mins[i], maxT = maxs[i]
                let left = (minT - rangeMin) / max(rangeMax - rangeMin, 1)
                let width = max((maxT - minT) / max(rangeMax - rangeMin, 1), 0.08)

                HStack(spacing: 10) {
                    Text(dayLabel(t, index: i)).font(.subheadline).fontWeight(.semibold).frame(width: 42, alignment: .leading)
                    WeatherGlyph(kind: weatherKind(for: weather.daily.weatherCode[i]), size: 22, accent: currentScene.accent)
                    Text("\(toUnit(minT))°").font(.subheadline).opacity(0.75).frame(width: 30, alignment: .trailing)
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.18)).frame(height: 5)
                            Capsule().fill(currentScene.accent)
                                .frame(width: max(g.size.width * width, 10), height: 5)
                                .offset(x: g.size.width * left)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    .frame(height: 5)
                    Text("\(toUnit(maxT))°").font(.subheadline).fontWeight(.semibold).frame(width: 30, alignment: .trailing)
                }
                .padding(.vertical, 8)
                if i < weather.daily.time.count - 1 {
                    Divider().opacity(0.15)
                }
            }
        }
        .foregroundStyle(currentScene.text)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private func detailGrid(_ weather: WeatherResponse) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            detailCard("Humedad", "\(weather.current.relativeHumidity2m)%", "Nivel relativo de agua en el aire")
            detailCard("Viento", "\(Int(weather.current.windSpeed10m.rounded())) km/h", "Velocidad actual")
            detailCard("Índice UV", "\(Int((weather.current.uvIndex ?? 0).rounded()))", uvLabel(weather.current.uvIndex ?? 0))
            detailCard("Prob. lluvia", "\(weather.daily.precipitationProbabilityMax.first ?? 0)%", "Máxima hoy")
        }
        .padding(.horizontal, 16)
    }

    private func detailCard(_ label: String, _ value: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.caption2).opacity(0.75)
            Text(value).font(.title2).fontWeight(.semibold)
            Text(sub).font(.caption2).opacity(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .foregroundStyle(currentScene.text)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Helpers de datos y formato

private struct HourPoint { let time: String; let temp: Double; let code: Int }

private func nextHours(_ weather: WeatherResponse) -> [HourPoint] {
    let now = weather.current.time
    let startIndex = weather.hourly.time.firstIndex(where: { $0 >= now }) ?? 0
    var out: [HourPoint] = []
    for i in 0..<8 {
        let j = startIndex + i
        guard j < weather.hourly.time.count else { break }
        out.append(HourPoint(time: weather.hourly.time[j], temp: weather.hourly.temperature2m[j], code: weather.hourly.weatherCode[j]))
    }
    return out
}

private func hourLabel(_ iso: String) -> String {
    guard let date = isoFormatter.date(from: iso) else { return "" }
    let f = DateFormatter()
    f.locale = Locale(identifier: "es_CL")
    f.dateFormat = "h a"
    return f.string(from: date)
}

private func dayLabel(_ iso: String, index: Int) -> String {
    if index == 0 { return "Hoy" }
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    guard let date = f.date(from: iso) else { return iso }
    let out = DateFormatter()
    out.locale = Locale(identifier: "es_CL")
    out.dateFormat = "EEE"
    return out.string(from: date).capitalized
}

private func uvLabel(_ uv: Double) -> String {
    switch uv {
    case ..<3: return "Bajo"
    case 3..<6: return "Moderado"
    case 6..<8: return "Alto"
    case 8..<11: return "Muy alto"
    default: return "Extremo"
    }
}

private let isoFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm"
    f.timeZone = TimeZone.current
    return f
}()

#Preview {
    ContentView()
}
