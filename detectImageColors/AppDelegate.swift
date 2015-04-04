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

    @IBOutlet weak var window: NSWindow!

    var colorTunes: ColorTunes?

    func applicationWillFinishLaunching(notification: NSNotification) {
        
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let pic = NSImage(named: "mic")
        colorTunes = ColorTunes(image: pic!, size: NSMakeSize(120.0, 120.0))
        println(colorTunes!.primaryColor!)
        println(colorTunes!.detailColor!)
        println(colorTunes!.backgroundColor!)
        println("before crash")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

