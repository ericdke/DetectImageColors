// DEMO APP

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appController: AppController!
    
    let filesManager = FilesManager()
    var presets = [Preset]()
    var defaultPresets = [Preset]()

    func applicationWillFinishLaunching(_ notification: Notification) {
        window.setFrameUsingName(NSWindow.FrameAutosaveName(rawValue: "DetectImageColorsDemo"))
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        do {
            if let apData = filesManager.defaultPresetsData,
                let apJSON = try JSONSerialization.jsonObject(with: apData, options: []) as? [[String:AnyObject]] {
                for pres in apJSON {
                    let p = Preset(name: pres["name"] as! String,
                                   brightness: pres["brightness"] as! CGFloat,
                                   distinct: pres["distinct"] as! CGFloat,
                                   saturation: pres["saturation"] as! CGFloat,
                                   contrast: pres["contrast"] as! CGFloat,
                                   noise: pres["noise"] as! Int,
                                   contrasted: pres["contrasted"] as! Bool,
                                   defaultPreset: pres["defaultPreset"] as! Bool)
                    defaultPresets.append(p)
                }
            }
        } catch {
            print(error)
            fatalError()
        }
        filesManager.save(defaultSettings: defaultSettings)
        let allPresets = filesManager.allPresets
        if !allPresets.isEmpty {
            self.presets = allPresets
        } else {
            self.presets = defaultPresets.sorted { $0.name < $1.name }
        }
        appController.presetsPanel.populatePresets(def: defaultPresets, all: presets)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        window.saveFrame(usingName: NSWindow.FrameAutosaveName(rawValue: "DetectImageColorsDemo"))
        saveNamedColors()
    }

    private func saveNamedColors() {
        if let path = filesManager.getJSONFilePath() {
            do {
                let enc = try JSONSerialization.data(withJSONObject: appController.namedColors, options: .prettyPrinted)
                try filesManager.saveColorNamesFile(data: enc, path: path)
            } catch let demoAppError as DemoAppError {
                print(demoAppError.rawValue)
            } catch {
                print(error)
            }
        }
    }

    private var defaultSettings: NSDictionary {
        return ["ThresholdDistinctColor": CDSettings.thresholdDistinctColor,
                "ThresholdNoiseTolerance": CDSettings.thresholdNoiseTolerance,
                "ThresholdMinimumSaturation": CDSettings.thresholdMinimumSaturation,
                "ThresholdFloorBrightness": CDSettings.thresholdFloorBrightness,
                "ContrastRatio": CDSettings.contrastRatio]
    }

}

