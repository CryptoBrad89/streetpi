# StreetPi

StreetPi is a native iPhone and iPad app for the Street house. One app, one experience. It says what the house is doing in plain English.

The screen is drawn from fake fixtures. It does not talk to the Pi, the router, or any other host.

Ad blocker & DNS opens the filter. Today shows blocking and a 24-hour chart of lookups. The only writes are a timed pause, blocking one domain, and allowing one domain. Each one asks in plain English first. Clients, groups, lists, local names, and upkeep are read-only. The text log file can be off; lookups are still kept. The app password and the Pi certificate pin stay in the Keychain. Nothing in this build opens a socket.

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

Snapshots cover Home, the ad blocker pages, Settings, and the intro, in dark and light, default and largest Dynamic Type, on a small iPhone, a large iPhone, and an iPad.
