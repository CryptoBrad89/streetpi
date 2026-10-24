struct AfterglowMotionGate: Equatable {
    var reduceMotion: Bool
    var still: Bool
    var reduceTransparency: Bool

    /// Breathing, blur, glints, and rolling numbers.
    var holdsMotion: Bool { !reduceMotion && !still }

    /// Snapshot stand-in and Reduce Transparency both paint solid plates.
    var usesSolidPlate: Bool { still || reduceTransparency }
}
