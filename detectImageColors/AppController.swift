//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    var colorDetector: ColorDetector?
    var colors: ColorCandidates?

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
        if let dic = notification.userInfo as? [String:String], let type = dic["type"] {
            if type == "path" {
                if let path = dic["path"], let img = NSImage(contentsOfFile: path) {
                    go(img)
                }
            } else {
                // synchronous, I know, it's temporary
                // and it's because I don't know how to grab the existing image
                if let path = dic["path"], let url = NSURL(string: path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!), let img = NSImage(contentsOfURL: url) {
                    go(img)
                }
            }
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

    // Smaller = faster = less accurate
    // Quality of analysis drops when below 600
    func resize(image: NSImage) -> NSImage {
        var destSize = NSMakeSize(CGFloat(600.0), CGFloat(600.0))
        var newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.drawInRect(NSMakeRect(0, 0, destSize.width, destSize.height), fromRect: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.CompositeSourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.TIFFRepresentation!)!
    }

    // Warning: do not feed with huge images
    func analyze(image: NSImage) {
        if let ct = colorDetector {
            colors = ct.analyzeImage(resize(image))
        } else {
            colorDetector = ColorDetector()
            colors = colorDetector!.analyzeImage(resize(image))
        }
    }

    func refresh() {
        if let ct = colorDetector, let cd = colors {
            label1.textColor = cd.primary
            label2.textColor = cd.secondary
            label3.textColor = cd.detail
            window.backgroundColor = cd.background
        }
    }

}
