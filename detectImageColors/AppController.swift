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
        go(NSImage(named: "elton")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageDropped:", name: "updateImageByDropOK", object: nil)
    }

    func imageDropped(notification: NSNotification) {
        if let dic = notification.userInfo as? [String:String], let type = dic["type"] {
            if type == "path" {
                if let path = dic["path"], let img = NSImage(contentsOfFile: path) {
                    go(img)
                }
            } else {
                if let path = dic["path"], let url = NSURL(string: path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!) {
                    let request = NSURLRequest(URL: url)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                        completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let dat = data, let img = NSImage(data: dat) {
                                self.go(img)
                            }
                        } else {
                            println("Error: \(error!.localizedDescription)")
                        }
                    })
                }
            }
        }
    }

    func go(image: NSImage) {
        analyze(image)
        imageView.image = image
        refresh()
    }

    // Image has to fill a square completely.
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
        if let cd = colorDetector {
            colors = cd.analyzeImage(resize(image))
        } else {
            colorDetector = ColorDetector()
            colors = colorDetector!.analyzeImage(resize(image))
        }
    }

    func refresh() {
        if let cd = colorDetector, let cl = colors {
            label1.textColor = cl.primary
            label2.textColor = cl.secondary
            label3.textColor = cl.detail
            window.backgroundColor = cl.background
        }
    }

}
