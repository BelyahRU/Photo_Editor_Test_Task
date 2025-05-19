import Foundation
import SwiftUI

struct TextElement: Identifiable {
    let id = UUID()
    var text: String
    var fontName: String
    var fontSize: CGFloat
    var color: Color
    var position: CGSize
}
