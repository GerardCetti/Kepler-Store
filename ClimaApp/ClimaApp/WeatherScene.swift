import SwiftUI

struct WeatherScene {
    let sky: [Color]
    let accent: Color
    let text: Color
}

func scene(for code: Int, isDay: Bool) -> WeatherScene {
    switch weatherKind(for: code) {
    case .sun:
        return isDay
            ? WeatherScene(sky: [Color(hex: "5FA8E0"), Color(hex: "8FCBF2"), Color(hex: "F4D48A")], accent: Color(hex: "F7B733"), text: Color(hex: "0B2545"))
            : WeatherScene(sky: [Color(hex: "0B1E3D"), Color(hex: "122C55"), Color(hex: "2A4270")], accent: Color(hex: "C9D6EA"), text: Color(hex: "EAF1FB"))
    case .cloud:
        return isDay
            ? WeatherScene(sky: [Color(hex: "7C93AC"), Color(hex: "A9BCCE"), Color(hex: "D8E1E8")], accent: Color(hex: "5C7285"), text: Color(hex: "1B2733"))
            : WeatherScene(sky: [Color(hex: "141C2B"), Color(hex: "243044"), Color(hex: "3A4863")], accent: Color(hex: "8FA3BD"), text: Color(hex: "EAF1FB"))
    case .rain:
        return isDay
            ? WeatherScene(sky: [Color(hex: "3A4A5C"), Color(hex: "556E82"), Color(hex: "7C93A3")], accent: Color(hex: "6FB6D9"), text: Color(hex: "EAF1FB"))
            : WeatherScene(sky: [Color(hex: "0D1420"), Color(hex: "1B2635"), Color(hex: "2C3B4E")], accent: Color(hex: "5E8CAD"), text: Color(hex: "EAF1FB"))
    case .snow:
        return WeatherScene(sky: [Color(hex: "7A8CA3"), Color(hex: "B9C7D6"), Color(hex: "EDF2F6")], accent: Color(hex: "3E5872"), text: Color(hex: "14202C"))
    case .storm:
        return WeatherScene(sky: [Color(hex: "1A1626"), Color(hex: "2E2440"), Color(hex: "4A3B5C")], accent: Color(hex: "E3B23C"), text: Color(hex: "F3EEFA"))
    case .fog:
        return WeatherScene(sky: [Color(hex: "8A8F94"), Color(hex: "B4B8BC"), Color(hex: "DCDEE0")], accent: Color(hex: "5A5F63"), text: Color(hex: "1E2224"))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
