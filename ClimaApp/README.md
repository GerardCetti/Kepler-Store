# ClimaApp — proyecto SwiftUI para iOS

App de clima nativa en SwiftUI (misma idea de diseño que la versión web que armamos:
gradientes dinámicos según el clima, glifos animados, pronóstico por horas y 7 días),
usando la API gratuita de [Open-Meteo](https://open-meteo.com) — no necesita API key.

## Antes de empezar: qué es realista sin Mac

No tengo forma de generarte un `.ipa` ya firmado — Apple exige que todo binario de iOS
esté firmado con un certificado ligado a una cuenta de Apple, y eso no se puede hacer
desde este entorno. Lo que sí monté es un pipeline que corre **enteramente en la nube**
(GitHub Actions, sin que tú necesites una Mac) y te deja el `.ipa` listo para descargar.
Pero para que ese `.ipa` se pueda instalar en un iPhone real, en algún punto **tiene que
quedar firmado con tu identidad de Apple**. Hay dos caminos:

### Camino A — Gratis, con AltStore / SideStore (recomendado si no quieres pagar)
1. El workflow de Actions compila un `.ipa` sin firmar (o con firma "development" vacía).
2. Instalas **AltServer** (Windows/macOS) o usas **SideStore** (solo necesita un iPhone,
   sin PC) — ambos son gratuitos.
3. Con tu Apple ID gratuito, AltStore/SideStore firman el `.ipa` localmente y lo instalan
   en tu iPhone. Limitación: hay que "refrescar" la firma cada 7 días (abriendo la app
   AltStore una vez), porque Apple limita así las firmas gratuitas.
4. No necesitas Mac, Xcode, ni pagar los 99 USD/año.

### Camino B — Cuenta de Apple Developer (99 USD/año), sin re-firmar cada semana
1. Generas un CSR (Certificate Signing Request) con `openssl` desde **cualquier sistema**
   (Windows, Linux o Mac):
   ```
   openssl genrsa -out ios.key 2048
   openssl req -new -key ios.key -out ios.csr -subj "/CN=Tu Nombre/[email protected]"
   ```
2. Subes `ios.csr` a [developer.apple.com](https://developer.apple.com) → Certificates →
   descargas el `.cer`, lo conviertes a `.p12` con tu `ios.key`.
3. Registras el UDID de tu iPhone y creas un **Ad Hoc Provisioning Profile** en el portal.
4. Subes el `.p12` y el `.mobileprovision` como *secrets* en GitHub (ver más abajo) y
   activas el paso de firma comentado en `.github/workflows/build-ipa.yml`.
5. El `.ipa` que descargas del workflow queda firmado y listo para instalar con
   **Sideloadly**, **Diawi** o directamente **TestFlight** (si subes el build a
   App Store Connect) — sin refirmar cada semana, válido ~1 año.

Te recomiendo empezar por el Camino A: es gratis y no requiere nada especial de tu parte.

## Estructura del proyecto

```
ClimaApp/
├── project.yml                  # especificación XcodeGen (genera el .xcodeproj)
├── ClimaApp/
│   ├── ClimaAppApp.swift        # punto de entrada
│   ├── ContentView.swift        # pantalla principal
│   ├── WeatherModels.swift      # modelos Codable de Open-Meteo
│   ├── WeatherService.swift     # llamadas de red (async/await)
│   ├── WeatherScene.swift       # colores/gradientes por condición climática
│   ├── WeatherGlyph.swift       # ícono animado (SF Symbols)
│   ├── LocationManager.swift    # ubicación del usuario (CoreLocation)
│   └── Info.plist
└── .github/workflows/build-ipa.yml
```

## Opción 1: compilar con Xcode (si en algún momento tienes acceso a una Mac)

1. Instala [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
2. En la carpeta del proyecto: `xcodegen generate`
3. Abre `ClimaApp.xcodeproj`, selecciona tu equipo de firma en
   *Signing & Capabilities*, conecta tu iPhone y presiona ▶.

## Opción 2: compilar en la nube con GitHub Actions (tu caso)

1. Crea un repositorio nuevo en GitHub y sube esta carpeta completa.
2. Ve a la pestaña **Actions** de tu repo → el workflow "Build IPA" corre solo
   (o dispáralo manualmente con "Run workflow").
3. Al terminar, descarga el artefacto `ClimaApp-build` desde la misma ejecución
   — ahí está el `.xcarchive` y, si configuraste firma (Camino B), el `.ipa`.
4. Instala en tu iPhone con AltStore/SideStore (Camino A) o Sideloadly (Camino B).

## Notas técnicas
- Pide permiso de ubicación (`NSLocationWhenInUseUsageDescription`) para el botón "usar mi ubicación".
- Todo el clima viene de Open-Meteo: clima actual, por horas y 7 días, sin necesidad de API key.
- Compatible desde iOS 16.
