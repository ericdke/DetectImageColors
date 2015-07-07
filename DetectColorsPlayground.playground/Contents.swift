//: DetectImageColors Playground

// Open the "Assistant Editor" to view results

import Cocoa
import XCPlayground

class DemoView: NSView {
    var color: NSColor? {
        didSet {
            self.display()
        }
    }
    init(frame frameRect: NSRect, color: NSColor) {
        super.init(frame: frameRect)
        self.color = color
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    tf.alignment = .Center
    tf.bordered = false
    return tf
}

// ---
CDSettings.DetectorResolutionX = 5
CDSettings.DetectorResolutionY = 1
CDSettings.ProcessedImageSize = 200
CDSettings.ThresholdDistinctColor = 0.25
CDSettings.ContrastRatio = 1.6

let image = NSImage(named: "elton")!
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)!
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized)!

let primaryColor = colorCandidates.primary!
let secondaryColor = colorCandidates.secondary!
let detailColor = colorCandidates.detail!
let backgroundColor = colorCandidates.background!

let mainView = NSView(frame: NSMakeRect(0, 0, 600, 600))
let imageView = NSImageView(frame: NSMakeRect(150, 250, 300, 300))
imageView.image = image

mainView.addSubview(DemoView(frame: NSMakeRect(0, 0, 600, 600), color: backgroundColor))
mainView.addSubview(imageView)
mainView.addSubview(DemoView(frame: NSMakeRect(100, 50, 100, 150), color: primaryColor))
mainView.addSubview(makeTextField(NSMakeRect(100, 20, 100, 20), color: primaryColor, background: backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(100, 60, 100, 20), color: backgroundColor, background: primaryColor))
mainView.addSubview(DemoView(frame: NSMakeRect(250, 50, 100, 150), color: secondaryColor))
mainView.addSubview(makeTextField(NSMakeRect(250, 20, 100, 20), color: secondaryColor, background: backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(250, 60, 100, 20), color: backgroundColor, background: secondaryColor))
mainView.addSubview(DemoView(frame: NSMakeRect(400, 50, 100, 150), color: detailColor))
mainView.addSubview(makeTextField(NSMakeRect(400, 20, 100, 20), color: detailColor, background: backgroundColor))
mainView.addSubview(makeTextField(NSMakeRect(400, 60, 100, 20), color: backgroundColor, background: detailColor))

XCPShowView("Colors", view: mainView)