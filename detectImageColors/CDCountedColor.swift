import Cocoa

struct CDCountedColor {
    var color: NSColor
    var count: Int
    init(color: NSColor, count: Int) {
        self.color = color
        self.count = count
    }
}
