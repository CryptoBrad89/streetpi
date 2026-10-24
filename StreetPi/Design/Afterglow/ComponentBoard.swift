import SwiftUI

/// The gallery's full stack. Snapshots measure this at each device width.
struct ComponentBoard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AfterglowShape.block) {
            BriefingSample()
            VitalsSample()
            RoomsSample()
        }
        .padding(AfterglowShape.page)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
