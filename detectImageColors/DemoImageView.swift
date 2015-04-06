//
//  ImageViewController.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 06/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class DemoImageView: NSImageView, NSDraggingDestination {

    override func drawRect(dirtyRect: NSRect) {
        let context = NSGraphicsContext.currentContext()!
        context.imageInterpolation = NSImageInterpolation.High
        super.drawRect(dirtyRect)
    }

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif"]
    var fileTypeIsOk = false

    required init?(coder: NSCoder) {
        let types = [NSFilenamesPboardType,NSURLPboardType,NSPasteboardTypeTIFF]
        super.init(coder: coder)
        registerForDraggedTypes(types)
    }

    override func viewDidMoveToWindow() {
        let trackingArea = NSTrackingArea(rect: self.bounds, options: (NSTrackingAreaOptions.ActiveInActiveApp | NSTrackingAreaOptions.MouseEnteredAndExited | NSTrackingAreaOptions.MouseMoved), owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
        self.becomeFirstResponder()
        self.toolTip = "Drop an image here."
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var go = false
        var dic = [String:String]()
        if let p1 = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            if let pathStr = p1[0] as? String {
                if checkExtension(pathStr) {
                    dic["path"] = pathStr
                    dic["type"] = "path"
                    go = true
                }
            }
        } else if let p2 = sender.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? NSArray {
            if let pathStr = p2[0][0] as? String {
                dic["path"] = pathStr
                dic["type"] = "url"
                go = true
            }
        }
        if go {
            NSNotificationCenter.defaultCenter().postNotificationName("updateImageByDropOK", object: nil, userInfo: dic)
        }
        return go
    }

    func checkExtension(pathStr: String) -> Bool {
        var go = false
        if let url = NSURL(fileURLWithPath: pathStr) {
            let suffix = url.pathExtension!
            for ext in fileTypes {
                if ext.lowercaseString == suffix {
                    go = true
                    break
                }
            }
        }
        return go
    }

}
