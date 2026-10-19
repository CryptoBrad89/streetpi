# StreetPi

StreetPi is a native iPhone and iPad app for the Street house. One app, one experience. It says what the house is doing in plain English.

Phase 1 is the foundation and three design directions. The screen is drawn from fake fixtures. It does not talk to the Pi, the router, or any other host.

## Design directions

- **Lampblack** — editorial type on a warm black page. Light mode is paper.
- **Harbor** — a cool instrument grid with a teal rail. Light mode is fog.
- **Porch** — one household card. Dark mode uses Liquid Glass on iOS 26; light mode is a cream card.

Settings includes Appearance (System, Dark, Light) and the direction switch so the three can be compared. Dark is the primary design.

## Layout

- `StreetPiCore` — domain model, plain-English status, fixture clients. Pure Swift. `make test-core` runs on Linux.
- `StreetPi` — SwiftUI app. iOS 18 minimum, iPhone and iPad.
- `StreetPi.xcodeproj` — open this, or `StreetPi.xcworkspace`.

Bundle id defaults to `com.streetfam.streetpi`. Override `STREETPI_BUNDLE_IDENTIFIER` in `Config/Shared.xcconfig`. `STREETPI_APP_GROUP_IDENTIFIER` is reserved and is not an entitlement yet.

Secrets go in the iOS Keychain (`KeychainSecretStore`). Tests use `MemorySecretStore` and the string `fixture-not-a-real-secret`.

## CI

GitHub Actions runs the core tests on Ubuntu and, on a standard `macos-26` runner, the snapshot matrix plus an unsigned `StreetPi-unsigned.ipa`. Do not move that job to a large or extra-large runner.

Snapshots cover each direction, Settings, and the intro, in dark and light, default and largest Dynamic Type, on a small iPhone, a large iPhone, and an iPad.
