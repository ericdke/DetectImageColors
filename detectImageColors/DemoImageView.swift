//
//  ImageViewController.swift
//  detectImageColors

import Cocoa

class DemoImageView: NSImageView, NSDraggingDestination {
    
    // Demo App
    
    // ------------------------------------
    
    // INIT
    
    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif"]
    let draggedTypes = [NSFilenamesPboardType,NSURLPboardType,NSPasteboardTypeTIFF]
    var fileTypeIsOk = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes(self.draggedTypes)
    }
    
    override func viewDidMoveToWindow() {
        let trackingArea = NSTrackingArea(rect: self.bounds, options: (NSTrackingAreaOptions.ActiveInActiveApp | NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.MouseMoved), owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.becomeFirstResponder()
        self.toolTip = "Drop an image here."
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
    // ------------------------------------
    
    // DRAG AND DROP ON IMAGE VIEW

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var go = false
        var dic = [String:String]()
        if let p1 = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray,
            let pathStr = p1[0] as? String where self.checkExtension(pathStr) {
                dic["path"] = pathStr
                dic["type"] = "path"
                go = true
        } else if let p2 = sender.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? NSArray, let pathStr = p2[0][0] as? String {
            dic["path"] = pathStr
            dic["type"] = "url"
            go = true
        }
        if go {
            self.imageDropped(dic)
        }
        return go
    }
    
    // HELPERS
    
    func imageDropped(dic: [String:String]) {
        if let type = dic["type"] {
            // it's a file
            if type == "path" {
                if let path = dic["path"], let img = NSImage(contentsOfFile: path) {
                    self.updateImage(img)
                }
            } else {
                // it's an url
                if let path = dic["path"], let escapedPath = path.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding), let url = NSURL(string: escapedPath) {
                    NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL: url), queue: NSOperationQueue.mainQueue(),
                        completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let dat = data, let img = NSImage(data: dat) {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.updateImage(img)
                                    }
                                }
                            } else {
                                println("Error: \(error!.localizedDescription)")
                            }
                    })
                }
            }
        }
    }
    
    private func updateImage(image: NSImage) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateImageByDropOK", object: nil, userInfo: ["image": image])
    }

    private func checkExtension(pathStr: String) -> Bool {
        if let url = NSURL(fileURLWithPath: pathStr), let suffix = url.pathExtension {
            for ext in self.fileTypes {
                if ext.lowercaseString == suffix {
                    return true
                }
            }
        }
        return false
    }

}
