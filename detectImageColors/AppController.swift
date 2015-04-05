//
//  AppController.swift
//  detectImageColors
//  Demo app

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
        if let path = selectImage(), let img = NSImage(contentsOfFile: path) {
            if let ct = colorTunes {
                // using the existing ColorTunes instance
                ct.analyzeImage(img)
            } else {
                // create instance of ColorTunes (automatically launches `analyzeImage`)
                colorTunes = ColorTunes(image: img, size: NSMakeSize(120.0, 120.0))
            }
            self.imageView.image = img
            refresh(img)
        }
    }

    func selectImage() -> String? {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.allowedFileTypes = ["jpg", "jpeg", "png"]
        myFiledialog.title = "Choose image"
        myFiledialog.runModal()
        if let chosenfile = myFiledialog.URL {
            return chosenfile.path
        }
        return nil
    }

    func refresh(image: NSImage) {
        if let ct = colorTunes, let cd = ct.candidates {
            NSLog("%@", cd.primary!)
            NSLog("%@", cd.secondary!)
            NSLog("%@", cd.detail!)
            NSLog("%@", cd.background!)
            label1.textColor = cd.primary
            label2.textColor = cd.secondary
            label3.textColor = cd.detail
            window.backgroundColor = cd.background
        }
    }

}
