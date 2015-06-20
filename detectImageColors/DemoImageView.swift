//
//  ImageViewController.swift
//  detectImageColors

import Cocoa

enum DragType {
    case Path, URL
}

class DemoImageView: NSImageView, NSDraggingDestination {

    let primaryDemoColorView = DemoColorView()
    let secondaryDemoColorView = DemoColorView()
    let detailDemoColorView = DemoColorView()
    let backgroundDemoColorView = DemoColorView()

    override func drawRect(dirtyRect: NSRect) {
        addColorView()
        super.drawRect(dirtyRect)
    }

    func addColorView() {
        primaryDemoColorView.frame = NSMakeRect(50, (self.bounds.height / 2) - 25, 50, 50)
        primaryDemoColorView.isMovable = true
        secondaryDemoColorView.frame = NSMakeRect(125, (self.bounds.height / 2) - 25, 50, 50)
        secondaryDemoColorView.isMovable = true
        detailDemoColorView.frame = NSMakeRect(200, (self.bounds.height / 2) - 25, 50, 50)
        detailDemoColorView.isMovable = true
        backgroundDemoColorView.frame = NSMakeRect(275, (self.bounds.height / 2) - 25, 50, 50)
        backgroundDemoColorView.isMovable = true
        self.addSubview(primaryDemoColorView)
        self.addSubview(secondaryDemoColorView)
        self.addSubview(detailDemoColorView)
        self.addSubview(backgroundDemoColorView)
    }

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif"]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSFilenamesPboardType,NSURLPboardType,NSPasteboardTypeTIFF])
    }

    override func viewDidMoveToWindow() {
        toolTip = "Drop an image here."
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let p1 = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? [AnyObject],
            let pathStr = p1[0] as? String where checkExtension(pathStr) {
                imageDropped((.Path, pathStr))
                return true
        } else if let p2 = sender.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? [AnyObject], let pathStr = p2[0][0] as? String {
            imageDropped((.URL, pathStr))
            return true
        }
        return false
    }

    private func imageDropped(paste: (type: DragType, value: String)) {
        if paste.type == .Path {
            if let img = NSImage(contentsOfFile: paste.value) {
                updateImage(img)
            }
        } else {
            if let escapedPath = paste.value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), let url = NSURL(string: escapedPath) {
                downloadImage(url)
            }
        }
    }

    private func downloadImage(url: NSURL) {
        NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url), queue: NSOperationQueue.mainQueue(),
            completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let dat = data, let img = NSImage(data: dat) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateImage(img)
                        }
                    }
                } else {
                    NSLog("%@", error!.localizedDescription)
                }
        })
    }

    private func updateImage(image: NSImage) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateImageByDropOK", object: nil, userInfo: ["image": image])
    }

    private func checkExtension(pathStr: String) -> Bool {
        if let url = NSURL(fileURLWithPath: pathStr), let suffix = url.pathExtension {
            for ext in fileTypes {
                if ext == suffix.lowercaseString {
                    return true
                }
            }
        }
        return false
    }

}
