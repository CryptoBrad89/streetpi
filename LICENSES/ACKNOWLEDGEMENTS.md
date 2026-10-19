# Acknowledgements

StreetPi does not copy Open Pi, Pi-hole Remote, their text, their icons, or their screenshots.

Phase 1 vendors no third-party source trees. Dependencies are fetched by Swift Package Manager:

| Project | Use | License | URL |
|---|---|---|---|
| swift-snapshot-testing | Visual tests for the iOS app | MIT | https://github.com/pointfreeco/swift-snapshot-testing |
| Swift toolchain | Builds StreetPiCore | Apache-2.0 | https://swift.org |

Later phases may use these permissive libraries, with their copyright notices kept: SwiftTerm (MIT), Citadel (MIT) or swift-nio-ssh (Apache-2.0), Runestone (MIT), Bunn/PiStats (BSD-2-Clause), Holeberry (MIT), SwiftHole (BSD-2-Clause), Beszel-Swift-App (MIT), reeve (MIT), nextdns/services (MIT), mmotti/pihole-regex (MIT).

Do not vendor PiStatsMobile (no license), raspiBackup (GPL-3.0), or AdGuard HostlistsRegistry (GPL-3.0).
