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

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
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
        if checkExtension(sender).boolValue == true {
            fileTypeIsOk = true
            return .Copy
        } else {
            fileTypeIsOk = false
            return .None
        }
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOk == true {
            return .Copy
        } else {
            return .None
        }
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        var go = false
        var dic = [String:String]()
        if let p1 = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            if let pathStr = p1[0] as? String {
                dic["path"] = pathStr
                NSNotificationCenter.defaultCenter().postNotificationName("updateImageByDropOK", object: nil, userInfo: dic)
                go = true
            }
        } else {
            if let p2 = sender.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? NSArray {
                if let pathStr = p2[0][0] as? String {
                    dic["path"] = pathStr
                    NSNotificationCenter.defaultCenter().postNotificationName("updateImageByURLDropOK", object: nil, userInfo: dic)
                    go = true
                }
            }
        }
        return go
    }

    func doCheckExtension(pathStr: String) -> Bool {
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

    func checkExtension(drag: NSDraggingInfo) -> Bool {
        var go = false
        if let p1 = drag.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray {
            go = doCheckExtension(p1[0] as! String)
        }
        if go == false {
            if let p2 = drag.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? NSArray {
                go = doCheckExtension(p2[0][0] as! String)
            }
        }
        return go
    }

}
