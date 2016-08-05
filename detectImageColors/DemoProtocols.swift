// DEMO APP

import Cocoa

protocol ImageDropDelegate {
    func updateImage(image: NSImage)
}

protocol ControlsDelegate {
    func updateColorCandidates(mouseUp: Bool)
}
