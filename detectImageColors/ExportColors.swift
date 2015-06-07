//
//  ExportColors.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 07/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class ExportColors {

    class func saveJSONFile(colorCandidates: ColorCandidates) {
        if let dic = toDictionary(colorCandidates), json = toJSON(dic) {
            saveJSONFile(json)
        }
    }

    private class func toDictionary(colorCandidates: ColorCandidates) -> [String:[String:CGFloat]]? {
        var dic = [String:[String:CGFloat]]()
        if let primary = colorCandidates.primary, let primaryRGB = primary.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
            dic["main"] = ["red": primaryRGB.redComponent, "green": primaryRGB.greenComponent, "blue": primaryRGB.blueComponent]
            if let alternative = colorCandidates.secondary, let alternativeRGB = alternative.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
                dic["alternative"] = ["red": alternativeRGB.redComponent, "green": alternativeRGB.greenComponent, "blue": alternativeRGB.blueComponent]
                if let detail = colorCandidates.detail, let detailRGB = detail.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
                    dic["detail"] = ["red": detailRGB.redComponent, "green": detailRGB.greenComponent, "blue": detailRGB.blueComponent]
                    if let background = colorCandidates.background, let backgroundRGB = background.colorUsingColorSpaceName(NSCalibratedRGBColorSpace) {
                        dic["background"] = ["red": backgroundRGB.redComponent, "green": backgroundRGB.greenComponent, "blue": backgroundRGB.blueComponent]
                        return dic
                    }
                }
            }
        }
        return nil
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
        myFiledialog.title = "Select the destination"
        myFiledialog.canCreateDirectories = true
        let epoch = Int(NSDate.timeIntervalSinceReferenceDate())
        myFiledialog.nameFieldStringValue = "colors-\(epoch).json"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.URL, path = chosenfile.path {
                if NSFileManager.defaultManager().fileExistsAtPath(path) {
                    trashFile(path)
                }
                writeJSONFile(json, filePath: path)
            }
        }
    }

    private class func writeJSONFile(json: NSData, filePath: String) -> Bool {
        json.writeToFile(filePath, atomically: false)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath)
    }

    private class  func trashFile(path: String) {
        var err: NSError?
        NSFileManager.defaultManager().removeItemAtPath(path, error: &err)
        if let crash = err {
            NSLog("%@", crash.debugDescription)
        }
    }

}
