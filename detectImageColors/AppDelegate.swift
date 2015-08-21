//  DEMO APP

//  SWIFT 2

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appController: AppController!
    
    var presets = [Preset]()
    var defaultPresets = [Preset]()

    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        let bundle = NSBundle.mainBundle()
        do {
            if let apPath = bundle.pathForResource("defaultPresets", ofType: "json"), let apData = NSData(contentsOfFile: apPath), let apJSON = try NSJSONSerialization.JSONObjectWithData(apData, options: []) as? [[String:AnyObject]] {
                for pres in apJSON {
                    let p = Preset(name: pres["name"] as! String, brightness: pres["brightness"] as! CGFloat, distinct: pres["distinct"] as! CGFloat, saturation: pres["saturation"] as! CGFloat, contrast: pres["contrast"] as! CGFloat, noise: pres["noise"] as! Int, contrasted: pres["contrasted"] as! Bool, defaultPreset: pres["defaultPreset"] as! Bool)
                    defaultPresets.append(p)
                }
            }
        } catch {
            print(error)
            fatalError()
        }
        NSUserDefaults.standardUserDefaults().setObject(getDefaultSettings(), forKey: "defaultSettings")
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("allPresets") as? NSData,
            let presets = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Preset] {
            self.presets = presets
        } else {
            self.presets = defaultPresets.sort({ $0.name < $1.name })
        }
        NSNotificationCenter.defaultCenter().postNotificationName("populatePresetsOK", object: nil, userInfo: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        window.saveFrameUsingName("DetectImageColorsDemo")
        saveNamedColors()
    }

    private func saveNamedColors() {
        if let path = appController.getJSONFilePath() {
            do {
                let enc = try NSJSONSerialization.dataWithJSONObject(appController.namedColors, options: .PrettyPrinted)
                let written = enc.writeToFile(path, atomically: false)
                if !written { throw DemoAppError.CouldNotSaveColorNamesFile }
            } catch let demoAppError as DemoAppError {
                print(demoAppError.rawValue)
            } catch {
                print(error)
            }
        }
    }

    private func getDefaultSettings() -> NSDictionary {
        return ["ThresholdDistinctColor": CDSettings.ThresholdDistinctColor, "ThresholdNoiseTolerance": CDSettings.ThresholdNoiseTolerance, "ThresholdMinimumSaturation": CDSettings.ThresholdMinimumSaturation, "ThresholdFloorBrightness": CDSettings.ThresholdFloorBrightness, "ContrastRatio": CDSettings.ContrastRatio]
    }

}

