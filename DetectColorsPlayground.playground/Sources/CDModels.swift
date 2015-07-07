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
    var count: NSInteger
    init(color: NSColor, count: NSInteger) {
        self.color = color
        self.count = count
    }
}

extension String {
    var length: Int {
        get {
            return self.characters.count
        }
    }
}