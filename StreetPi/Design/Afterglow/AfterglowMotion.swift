import SwiftUI

enum AfterglowMotion {
    static let fast: TimeInterval = 0.12
    static let base: TimeInterval = 0.25
    static let slow: TimeInterval = 0.45
    static let hero: TimeInterval = 0.8
    static let breathe: TimeInterval = 7
    static let composeStep: TimeInterval = 0.08

    static var spring: Animation { .smooth(duration: slow) }
    static var snappy: Animation { .snappy }
    static var press: Animation { .easeOut(duration: fast) }
}
