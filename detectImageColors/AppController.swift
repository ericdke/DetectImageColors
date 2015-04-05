//
//  AppController.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 04/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class AppController: NSObject {

    var colorTunes: ColorTunes?

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var label4: NSTextField!
    @IBOutlet weak var imageView: NSImageView!

    @IBAction func open(sender: AnyObject) {
        if let path = selectImage() {
            if let img = NSImage(contentsOfFile: path) {
                if let ct = colorTunes {
                    ct.analyzeImage(img)
                } else {
                    colorTunes = ColorTunes(image: img, size: NSMakeSize(120.0, 120.0))
                }
                self.imageView.image = img
                refresh(img)
            }
        }
    }

    func selectImage() -> String? {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.allowedFileTypes = ["jpg", "jpeg", "png"]
        myFiledialog.title = "Choose image"
        myFiledialog.runModal()
        var path: String?
        if let chosenfile = myFiledialog.URL {
            path = chosenfile.path
        }
        return path
    }

    func refresh(image: NSImage) {
        NSLog("%@", colorTunes!.candidates!.primary!)
        NSLog("%@", colorTunes!.candidates!.secondary!)
        NSLog("%@", colorTunes!.candidates!.detail!)
        NSLog("%@", colorTunes!.candidates!.background!)
        label1.textColor = colorTunes!.candidates!.primary
        label2.textColor = colorTunes!.candidates!.secondary
        label3.textColor = colorTunes!.candidates!.detail
        window.backgroundColor = colorTunes!.candidates!.background
    }

}
