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

    func applicationWillFinishLaunching(notification: NSNotification) {
        self.window.setFrameUsingName("DetectImageColorsDemo")
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        self.window.saveFrameUsingName("DetectImageColorsDemo")
    }


}

