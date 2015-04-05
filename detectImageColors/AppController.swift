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
        colorTunes = ColorTunes(image: image, size: NSMakeSize(120.0, 120.0))
        let colors = colorTunes!.candidates!
        NSLog("%@", colors.primary!)
        NSLog("%@", colors.secondary!)
        NSLog("%@", colors.detail!)
        NSLog("%@", colors.background!)
        label1.textColor = colors.primary
        label2.textColor = colors.secondary
        label3.textColor = colors.detail
        window.backgroundColor = colors.background

    }

}
