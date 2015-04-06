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
    @IBOutlet weak var imageView: NSImageView!

    override func awakeFromNib() {
        go(NSImage(named: "reed")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDropped:", name: "updateImageByDropOK", object: nil)
    }

    @IBAction func open(sender: AnyObject) {
        if let path = selectImage(), let img = NSImage(contentsOfFile: path) {
            go(img)
        }
    }

    func imageDropped(notification: NSNotification) {
        let dic = notification.userInfo as! [String:String]
        if let path = dic["path"], let img = NSImage(contentsOfFile: path) {
            go(img)
        }
    }

    func selectImage() -> String? {
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        myFiledialog.title = "Choose image"
        myFiledialog.runModal()
        if let chosenfile = myFiledialog.URL {
            return chosenfile.path
        }
        return nil
    }

    func go(image: NSImage) {
        analyze(image)
        imageView.image = image
        refresh()
    }

    func analyze(image: NSImage) {
        if let ct = colorTunes {
            ct.analyzeImage(image)
        } else {
            colorTunes = ColorTunes(image: image, size: NSMakeSize(120.0, 120.0))
        }
    }

    func refresh() {
        if let ct = colorTunes, let cd = ct.candidates {
            label1.textColor = cd.primary
            label2.textColor = cd.secondary
            label3.textColor = cd.detail
            window.backgroundColor = cd.background
        }
    }

}
