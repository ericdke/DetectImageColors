//
//  AppDelegate.swift
//  detectImageColors

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Demo App
    
    // ------------------------------------

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var distinctColorsSlider: NSTextField!
    @IBOutlet weak var thresholdNoise: NSTextField!
    @IBOutlet weak var thresholdMinimumSaturation: NSTextField!
    @IBOutlet weak var thresholdFloorBrightness: NSTextField!
    @IBOutlet weak var contrastRatio: NSTextField!
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        distinctColorsSlider.doubleValue = 0.43
        thresholdNoise.integerValue = 1
        thresholdMinimumSaturation.doubleValue = 0.15
        thresholdFloorBrightness.doubleValue = 0.25
        contrastRatio.doubleValue = 0.18
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
    }


}

