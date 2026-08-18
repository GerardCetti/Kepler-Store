import SwiftUI

struct WeatherGlyph: View {
    let kind: WeatherKind
    var size: CGFloat = 100
    var accent: Color = .yellow

    @State private var animate = false

    var body: some View {
        Group {
            switch kind {
            case .sun:
                Image(systemName: "sun.max.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(accent)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(.linear(duration: 40).repeatForever(autoreverses: false), value: animate)
            case .cloud:
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(.white)
                    .offset(x: animate ? 4 : -4)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
            case .rain:
                Image(systemName: "cloud.rain.fill")
                    .resizable().scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, accent)
                    .offset(y: animate ? 2 : -2)
                    .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: animate)
            case .snow:
                Image(systemName: "cloud.snow.fill")
                    .resizable().scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, accent)
                    .rotationEffect(.degrees(animate ? 8 : -8))
                    .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: animate)
            case .storm:
                Image(systemName: "cloud.bolt.fill")
                    .resizable().scaledToFit()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(accent, Color(hex: "3A3352"))
                    .opacity(animate ? 1 : 0.4)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: animate)
            case .fog:
                Image(systemName: "cloud.fog.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(.white)
                    .offset(x: animate ? 5 : -5)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
            }
        }
        .frame(width: size, height: size)
        .onAppear { animate = true }
    }
}
