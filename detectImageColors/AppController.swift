//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {
    
    // ------------------------------------
    
    // Color Detector objects

    var colorDetector: ColorDetector?
    var colorCandidates: ColorCandidates?

    // Create color candidates from image
    
    private func analyzeImage(image: NSImage) {
        var candidates: ColorCandidates?
        // If our ColorDetector instance exists
        if let cd = self.colorDetector {
            // Avoid big images
            if let resized = cd.resize(image) {
                
                
                // Get the Optional ColorCandidates object from the resized image
                candidates = cd.getColorCandidatesFromImage(resized)
                
                
            }
        } else {
            
            
            // Create ColorDetector instance
            self.colorDetector = ColorDetector()
            
            
            if let cd = self.colorDetector, let resized = cd.resize(image) {
                candidates = cd.getColorCandidatesFromImage(resized)
            }
        }
        if let validCandidates = candidates {
            self.colorCandidates = validCandidates
        }
    }
    
    // ------------------------------------
    
    // Demo app IBOutlets
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    
    // Demo App methods

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
