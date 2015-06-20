//: DetectImageColors Playground

// Open the "Assistant Editor" to view results

import Cocoa
import XCPlayground

let image = NSImage(named: "elton")!
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized!)

// ---

class DemoView: NSView {
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

func makeTextField(frame: NSRect, color: NSColor, background: NSColor) -> NSTextField {
    let tf = NSTextField(frame: frame)
    tf.font = NSFont.systemFontOfSize(14)
    tf.textColor = color
    tf.backgroundColor = background
    tf.stringValue = tf.textColor!.componentsCSS()!.css
    tf.alignment = .CenterTextAlignment
    tf.bordered = false
    return tf
}

let mainView = NSView(frame: NSMakeRect(0, 0, 600, 600))
let imageView = NSImageView(frame: NSMakeRect(150, 250, 300, 300))
imageView.image = image
let primaryColorView = DemoView(frame: NSMakeRect(100, 50, 100, 150))
let secondaryColorView = DemoView(frame: NSMakeRect(250, 50, 100, 150))
let detailColorView = DemoView(frame: NSMakeRect(400, 50, 100, 150))
let backgroundColorView = DemoView(frame: NSMakeRect(0, 0, 600, 600))

let primaryColor = colorCandidates!.primary!
let secondaryColor = colorCandidates!.secondary!
let detailColor = colorCandidates!.detail!
let backgroundColor = colorCandidates!.background!

primaryColorView.color = primaryColor
secondaryColorView.color = secondaryColor
detailColorView.color = detailColor
backgroundColorView.color = backgroundColor

mainView.addSubview(backgroundColorView)
mainView.addSubview(imageView)
mainView.addSubview(primaryColorView)
mainView.addSubview(makeTextField(NSMakeRect(100, 20, 100, 20), primaryColor, backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(100, 170, 100, 20), backgroundColor, primaryColor))
mainView.addSubview(secondaryColorView)
mainView.addSubview(makeTextField(NSMakeRect(250, 20, 100, 20), secondaryColor, backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(250, 170, 100, 20), backgroundColor, secondaryColor))
mainView.addSubview(detailColorView)
mainView.addSubview(makeTextField(NSMakeRect(400, 20, 100, 20), detailColor, backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(400, 170, 100, 20), backgroundColor, detailColor))

XCPShowView("Colors", mainView)

