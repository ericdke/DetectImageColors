//  DEMO APP

//  SWIFT 2

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appController: AppController!
    
    let defaultPresets = [Preset(name: "Photo contrasted", brightness: 0.1, distinct: 0.5, saturation: 0.2, contrast: 1.2, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Photo monochrome", brightness: 0.04, distinct: 0.06, saturation: 0.2, contrast: 2.7, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Photo warm colors", brightness: 0.12, distinct: 0.22, saturation: 0.07, contrast: 1.8, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Photo blurry", brightness: 0.3, distinct: 0.79, saturation: 0.09, contrast: 2.5, noise: 1, contrasted: true, defaultPreset: true), Preset(name: "Illustration shades hard", brightness: 0.26, distinct: 0.13, saturation: 0.38, contrast: 1.4, noise: 1, contrasted: true, defaultPreset: true), Preset(name: "Illustration shades soft", brightness: 0.1, distinct: 0.32, saturation: 0.1, contrast: 2, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Illustration detailed soft", brightness: 0.26, distinct: 0.27, saturation: 0.19, contrast: 2.5, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Illustration detailed hard", brightness: 0.25, distinct: 0.43, saturation: 0.15, contrast: 2.1, noise: 1, contrasted: true, defaultPreset: true), Preset(name: "Photo nature landscape", brightness: 0.16, distinct: 0.28, saturation: 0.35, contrast: 1.4, noise: 2, contrasted: false, defaultPreset: true), Preset(name: "Photo interior dark", brightness: 0.15, distinct: 0.18, saturation: 0.16, contrast: 2.8, noise: 1, contrasted: false, defaultPreset: true), Preset(name: "Photo interior nuanced", brightness: 0.05, distinct: 0.13, saturation: 0.3, contrast: 2.8, noise: 2, contrasted: true, defaultPreset: true), Preset(name: "Photo snow/fog", brightness: 0.33, distinct: 0.83, saturation: 0.05, contrast: 2.6, noise: 2, contrasted: true, defaultPreset: true)]
    var presets = [Preset]()

    func applicationWillFinishLaunching(notification: NSNotification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
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

