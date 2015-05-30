//
//  AppDelegate.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 04/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

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
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        distinctColorsSlider.doubleValue = 0.43
        thresholdNoise.integerValue = 1
        thresholdMinimumSaturation.doubleValue = 0.15
        thresholdFloorBrightness.doubleValue = 0.25
        contrastRatio.doubleValue = 0.18
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
    }


}

