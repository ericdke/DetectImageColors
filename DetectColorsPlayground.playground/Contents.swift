//: DetectImageColors Playground

// Open the "Assistant Editor" to view results

import Cocoa
import XCPlayground

let image = NSImage(named: "elton")!
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized!)

// ---

class DemoBackgroundView: NSView {
    var color: NSColor? {
        didSet {
            self.display()
        }
    }
    override func drawRect(dirtyRect: NSRect) {
        if let color = self.color {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        super.drawRect(dirtyRect)
    }
}

let mainView = NSView(frame: NSMakeRect(0, 0, 600, 600))
let imageView = NSImageView(frame: NSMakeRect(150, 250, 300, 300))
imageView.image = image
let primaryColorView = DemoBackgroundView(frame: NSMakeRect(100, 50, 100, 150))
let secondaryColorView = DemoBackgroundView(frame: NSMakeRect(250, 50, 100, 150))
let detailColorView = DemoBackgroundView(frame: NSMakeRect(400, 50, 100, 150))
let backgroundColorView = DemoBackgroundView(frame: NSMakeRect(0, 0, 600, 600))
primaryColorView.color = colorCandidates?.primary
secondaryColorView.color = colorCandidates?.secondary
detailColorView.color = colorCandidates?.detail
backgroundColorView.color = colorCandidates?.background

mainView.addSubview(backgroundColorView)
mainView.addSubview(imageView)
mainView.addSubview(primaryColorView)
mainView.addSubview(secondaryColorView)
mainView.addSubview(detailColorView)

XCPShowView("Colors", mainView)
