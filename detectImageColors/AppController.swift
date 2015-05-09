//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    // These two models come from CDModels.swift
    var colorDetector: ColorDetector?
    var colorCandidates: ColorCandidates?

    // Demo app IBOutlets
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var imageView: NSImageView!

    // Creates color candidates from image
    private func analyzeImage(image: NSImage) {
        // Warning: do not feed with huge images
        var candidates: ColorCandidates?
        if let cd = self.colorDetector {
            // Always resize your source image
            candidates = cd.getColorCandidatesFromImage(cd.resize(image))
        } else {
            self.colorDetector = ColorDetector()
            if let cd = self.colorDetector {
                candidates = cd.getColorCandidatesFromImage(cd.resize(image))
            }
        }
        self.colorCandidates = candidates
    }

    private func refreshWindowElements() {
        if let cols = self.colorCandidates {
            self.label1.textColor = cols.primary
            self.label2.textColor = cols.secondary
            self.label3.textColor = cols.detail
            self.window.backgroundColor = cols.background
        }
    }
    
    private func analyseImageAndRefreshWindowElements(image: NSImage) {
        self.analyzeImage(image)
        self.imageView.image = image
        self.refreshWindowElements()
    }
    
    override func awakeFromNib() {
        // Default image when demo app starts
        if let elton = NSImage(named: "elton") {
            self.analyseImageAndRefreshWindowElements(elton)
        }
        // Observe for dropped images
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
    }
    
    func updateImage(notification: NSNotification) {
        if let dic = notification.userInfo as? [String: NSImage], let img = dic["image"] {
            self.analyseImageAndRefreshWindowElements(img)
        }
    }

}
