//
//  AppDelegate.swift
//  detectImageColors

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
    }


}

