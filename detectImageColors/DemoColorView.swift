//  DEMO APP

//  SWIFT 2

import Cocoa

class DemoColorView: NSView {
    
    @IBOutlet weak var backgroundColorLabel: NSTextField!
    
    var isMovable = false
    
    var color: NSColor? {
        didSet {
            self.display()
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        if let color = self.color {
            color.setFill()
            NSRectFill(dirtyRect)
        }
        super.draw(dirtyRect)
    }
    override func mouseDragged(_ theEvent: NSEvent) {
        if isMovable {
            let deltax = theEvent.deltaX
            let deltay = theEvent.deltaY
            var frame = self.frame
            frame.origin.x += deltax
            frame.origin.y -= deltay
            self.setFrameOrigin(frame.origin)
        }
    }
}
