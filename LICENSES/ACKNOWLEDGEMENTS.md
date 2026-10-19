# Acknowledgements

StreetPi does not copy Open Pi, Pi-hole Remote, their text, their icons, or their screenshots.

StreetPi vendors no third-party source trees. Dependencies are fetched by Swift Package Manager:

| Project | Use | License | URL |
|---|---|---|---|
| swift-snapshot-testing | Visual tests for the iOS app | MIT | https://github.com/pointfreeco/swift-snapshot-testing |
| SwiftTerm 1.99.0 | Terminal view | MIT | https://github.com/migueldeicaza/SwiftTerm |
| swift-nio-ssh 0.15.0 | SSH client types (`NIOSSH`) | Apache-2.0 | https://github.com/apple/swift-nio-ssh |
| Runestone 0.5.2 | File editor | MIT | https://github.com/simonbs/Runestone |
| Swift toolchain | Builds StreetPiCore | Apache-2.0 | https://swift.org |

Citadel (MIT) was not linked. Its current release depends on a third-party fork of swift-nio-ssh. StreetPi uses Apple's swift-nio-ssh instead.

Later phases may use these permissive libraries, with their copyright notices kept: Bunn/PiStats (BSD-2-Clause), Holeberry (MIT), SwiftHole (BSD-2-Clause), Beszel-Swift-App (MIT), reeve (MIT), nextdns/services (MIT), mmotti/pihole-regex (MIT).

Do not vendor PiStatsMobile (no license), raspiBackup (GPL-3.0), or AdGuard HostlistsRegistry (GPL-3.0).
