// DEMO APP

import Cocoa

class DemoBackgroundView: NSView {

    var colorCandidates: ColorCandidates? {
        didSet {
            self.display()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        if let color = self.colorCandidates?.background {
            color.setFill()
            dirtyRect.fill()
        }
        super.draw(dirtyRect)
    }

}
