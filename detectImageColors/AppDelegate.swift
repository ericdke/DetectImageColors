//
//  AppDelegate.swift
//  detectImageColors

// DEMO APP

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var namedColors = [String:String]()

    func getJSONFilePath() -> String? {
        if let dirs:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
            return dirs[0].stringByAppendingPathComponent("colors_dic.json")
        }
        return nil
    }

    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        let defaultSettings = ["ThresholdDistinctColor": CDSettings.ThresholdDistinctColor, "ThresholdNoiseTolerance": CDSettings.ThresholdNoiseTolerance, "ThresholdMinimumSaturation": CDSettings.ThresholdMinimumSaturation, "ThresholdFloorBrightness": CDSettings.ThresholdFloorBrightness, "ContrastRatio": CDSettings.ContrastRatio]
        NSUserDefaults.standardUserDefaults().setObject(defaultSettings, forKey: "defaultSettings")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
        if let path = getJSONFilePath() {
            var err: NSError?
            let enc = NSJSONSerialization.dataWithJSONObject(namedColors, options: NSJSONWritingOptions.PrettyPrinted, error: &err)
            if err != nil {
                NSLog("%@", "Error while encoding colors to JSON")
            }
            if enc!.writeToFile(path, atomically: false) == false {
                NSLog("%@", "Error while writing JSON file")
            }
        }
    }

}

