//  SWIFT 2

import Cocoa

public struct ColorCandidates {
    public var primary: NSColor?
    public var secondary: NSColor?
    public var detail: NSColor?
    public var background: NSColor?
    public var backgroundIsDark: Bool?
    public var backgroundIsBlackOrWhite: Bool?
}

struct CDCountedColor {
    var color: NSColor
    var count: Int
    init(color: NSColor, count: Int) {
        self.color = color
        self.count = count
    }
}

