//
//  ExportColors.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 07/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class ExportColors {

    class DemoView: NSView {
        var color: NSColor?
        override func drawRect(dirtyRect: NSRect) {
            if let color = self.color {
                color.setFill()
                NSRectFill(dirtyRect)
            }
            super.drawRect(dirtyRect)
        }
    }

    class func saveJSONFile(colorCandidates: ColorCandidates) {
        if let dic = toDictionary(colorCandidates), json = toJSON(dic) {
            saveJSONFile(json)
        }
    }

    class func savePNGFile(png: NSData) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the PNG file"
        myFiledialog.canCreateDirectories = true
        let epoch = Int(NSDate.timeIntervalSinceReferenceDate())
        myFiledialog.nameFieldStringValue = "colors-\(epoch).png"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.URL, path = chosenfile.path {
                png.writeToFile(path, atomically: false)
            }
        }
    }

    class func makeColorView(colorCandidates: ColorCandidates, image: NSImage) -> NSView {
        let mainView = NSView(frame: NSMakeRect(0, 0, 600, 600))
        let imageView = NSImageView(frame: NSMakeRect(150, 250, 300, 300))
        imageView.image = image
        let primaryColorView = DemoView(frame: NSMakeRect(100, 50, 100, 150))
        let secondaryColorView = DemoView(frame: NSMakeRect(250, 50, 100, 150))
        let detailColorView = DemoView(frame: NSMakeRect(400, 50, 100, 150))
        let backgroundColorView = DemoView(frame: NSMakeRect(0, 0, 600, 600))
        primaryColorView.color = colorCandidates.primary
        secondaryColorView.color = colorCandidates.secondary
        detailColorView.color = colorCandidates.detail
        backgroundColorView.color = colorCandidates.background
        mainView.addSubview(backgroundColorView)
        mainView.addSubview(imageView)
        mainView.addSubview(primaryColorView)
        mainView.addSubview(secondaryColorView)
        mainView.addSubview(detailColorView)
        return mainView
    }

    class func makeColorView(colorCandidates: ColorCandidates) -> NSView {
        let mainView = NSView(frame: NSMakeRect(0, 0, 800, 200))
        let primaryColorView = DemoView(frame: NSMakeRect(0, 0, 200, 200))
        let secondaryColorView = DemoView(frame: NSMakeRect(200, 0, 200, 200))
        let detailColorView = DemoView(frame: NSMakeRect(400, 0, 200, 200))
        let backgroundColorView = DemoView(frame: NSMakeRect(600, 0, 200, 200))
        primaryColorView.color = colorCandidates.primary
        secondaryColorView.color = colorCandidates.secondary
        detailColorView.color = colorCandidates.detail
        backgroundColorView.color = colorCandidates.background
        mainView.addSubview(backgroundColorView)
        mainView.addSubview(primaryColorView)
        mainView.addSubview(secondaryColorView)
        mainView.addSubview(detailColorView)
        return mainView
    }

    class func makePNGFromView(view: NSView) -> NSData? {
        var rep = view.bitmapImageRepForCachingDisplayInRect(view.bounds)!
        view.cacheDisplayInRect(view.bounds, toBitmapImageRep: rep)
        if let data = rep.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:]) {
            return data
        }
        return nil
    }

    private class func toDictionary(colorCandidates: ColorCandidates) -> [String:[String:CGFloat]]? {
        var dic = [String:[String:CGFloat]]()
        if let primary = getRGBSpaceName(colorCandidates.primary) {
            dic["main"] = getDictionaryColorComponents(primary)
            if let alternative = getRGBSpaceName(colorCandidates.secondary) {
                dic["alternative"] = getDictionaryColorComponents(alternative)
                if let detail = getRGBSpaceName(colorCandidates.detail) {
                    dic["detail"] = getDictionaryColorComponents(detail)
                    if let background = getRGBSpaceName(colorCandidates.background) {
                        dic["background"] = getDictionaryColorComponents(background)
                        return dic
                    }
                }
            }
        }
        return nil
    }

    private class func getRGBSpaceName(color: NSColor?) -> NSColor? {
        if let thisColor = color, let rgbColor = thisColor.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            return rgbColor
        }
        return nil
    }

    private class func getDictionaryColorComponents(color: NSColor) -> [String:CGFloat] {
        return ["red": color.redComponent, "green": color.greenComponent, "blue": color.blueComponent]
    }

    private class func toJSON(colorCandidates: ColorCandidates) -> NSData? {
        if let dic = toDictionary(colorCandidates) {
            return toJSON(dic)
        }
        return nil
    }

    private class func toJSON(dictionary: [String:[String:CGFloat]]) -> NSData? {
        var err: NSError?
        if let json = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: &err) {
            if err == nil {
                return json
            }
            NSLog("%@", err!.localizedDescription)
        }
        return nil
    }

    private class func saveJSONFile(json: NSData) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the JSON file"
        myFiledialog.canCreateDirectories = true
        let epoch = Int(NSDate.timeIntervalSinceReferenceDate())
        myFiledialog.nameFieldStringValue = "colors-\(epoch).json"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.URL, path = chosenfile.path {
                json.writeToFile(path, atomically: false)
            }
        }
    }

    private class func trashFile(path: String) {
        var err: NSError?
        NSFileManager.defaultManager().removeItemAtPath(path, error: &err)
        if let crash = err {
            NSLog("%@", crash.debugDescription)
        }
    }

}


