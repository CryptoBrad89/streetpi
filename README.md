# StreetPi

StreetPi is a native iPhone and iPad app for the Street house. One app, one experience. It says what the house is doing in plain English.

The screen is drawn from fake fixtures. It does not talk to the Pi, the router, or any other host.

Ad blocker & DNS opens the filter. The house fixture has query logging off and local-name writes locked, so the log, the top lists, and the day chart explain why they are empty. A second fixture turns logging on and allows local names, and those screens fill in. Writes ask in plain English first. The hardest ones ask for Face ID. The app password stays in the Keychain.

Pi health is look-only. It shows meters for the processor, temperature, memory, disk, and uptime, plus a day chart. Services and containers are readings. Alerts stay in the app. Nothing here opens a connection, and the phone does not keep an SSH key or a host pin.

## Look

One direction. A warm rounded card says how the house is doing. Under it, labelled meters (Processor, Temperature, Memory, Disk), then a card for each part of the house. Dark is the primary design. Light mode is cream. Settings has Appearance: System, Dark, Light.

## Layout

- `StreetPiCore` — domain model, plain-English status, fixture clients. Pure Swift. `make test-core` runs on Linux.
- `StreetPi` — SwiftUI app. iOS 18 minimum, iPhone and iPad.
- `StreetPi.xcodeproj` — open this, or `StreetPi.xcworkspace`.

Bundle id defaults to `com.streetfam.streetpi`. Override `STREETPI_BUNDLE_IDENTIFIER` in `Config/Shared.xcconfig`. `STREETPI_APP_GROUP_IDENTIFIER` is reserved and is not an entitlement yet.

Secrets go in the iOS Keychain (`KeychainSecretStore`). Tests use `MemorySecretStore` and the strings `fixture-not-a-real-secret` and `fixture-not-a-real-password`. Those strings are never printed.

## CI

GitHub Actions runs the core tests on Ubuntu and, on a standard `macos-26` runner, the snapshot matrix plus an unsigned `StreetPi-unsigned.ipa`. Do not move that job to a large or extra-large runner.

Snapshots cover Home, the ad blocker pages in both logging states, the machine pages, alerts, Settings, and the intro, in dark and light, default and largest Dynamic Type, on a small iPhone, a large iPhone, and an iPad.
