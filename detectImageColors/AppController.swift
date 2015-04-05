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
    var sourcePic = NSImage(named: "reed")

    override init() {
        colorTunes = ColorTunes(image: sourcePic!, size: NSMakeSize(120.0, 120.0))
        super.init()
    }

    override func awakeFromNib() {
        refresh()
    }

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var label4: NSTextField!
    @IBOutlet weak var image: NSImageView!

    // there's a bug somewhere
    @IBAction func open(sender: AnyObject) {
        if let path = selectImage() {
            if let img = NSImage(contentsOfFile: path) {
                self.sourcePic = img
                colorTunes = ColorTunes(image: img, size: NSMakeSize(120.0, 120.0))
                refresh()
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

    func refresh() {
        self.colorTunes!.analyzeImage(self.sourcePic!)
        let colors = self.colorTunes!.getColorElements()
        NSLog("%@", colors.primary!)
        NSLog("%@", colors.secondary!)
        NSLog("%@", colors.detail!)
        NSLog("%@", colors.background!)
        self.label1.textColor = colors.primary!
        self.label2.textColor = colors.secondary!
        self.label3.textColor = colors.detail!
        self.window.backgroundColor = colors.background!
        image.image = self.sourcePic
    }



}
