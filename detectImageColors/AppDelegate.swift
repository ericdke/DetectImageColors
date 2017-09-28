// DEMO APP

import Cocoa

extension NSWindow {
    static let DetectImageColorsDemo = NSWindow.FrameAutosaveName(rawValue: "DetectImageColorsDemo")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appController: AppController!
    
    let filesManager = FilesManager()
    var presets = [Preset]()
    var defaultPresets = [Preset]()

    func applicationWillFinishLaunching(_ notification: Notification) {
        window.setFrameUsingName(NSWindow.DetectImageColorsDemo)
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        do {
            if let apData = filesManager.defaultPresetsData,
                let apJSON = try JSONSerialization.jsonObject(with: apData, options: []) as? [[String:AnyObject]] {
                for pres in apJSON {
                    guard let name = pres["name"] as? String,
                        let brightness = pres["brightness"] as? CGFloat,
                        let distinct = pres["distinct"] as? CGFloat,
                        let saturation = pres["saturation"] as? CGFloat,
                        let contrast = pres["contrast"] as? CGFloat,
                        let noise = pres["noise"] as? Int,
                        let contrasted = pres["contrasted"] as? Bool,
                        let defaultPreset = pres["defaultPreset"] as? Bool else
                    {
                        throw DemoAppError.couldNotLoadPresets
                    }
                    let p = Preset(name: name,
                                   brightness: brightness,
                                   distinct: distinct,
                                   saturation: saturation,
                                   contrast: contrast,
                                   noise: noise,
                                   contrasted: contrasted,
                                   defaultPreset: defaultPreset)
                    defaultPresets.append(p)
                }
            }
        } catch {
            DispatchQueue.main.async {
                Modals.alert(title: "Fatal error", info: error.localizedDescription, style: .critical)
                NSApp.terminate(nil)
            }
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
        window.saveFrame(usingName: NSWindow.DetectImageColorsDemo)
        saveNamedColors()
    }

    private func saveNamedColors() {
        if let path = filesManager.getJSONFilePath() {
            do {
                let enc = try JSONSerialization.data(withJSONObject: appController.namedColors, options: .prettyPrinted)
                try filesManager.saveColorNamesFile(data: enc, path: path)
            } catch {
                DispatchQueue.main.async {
                    Modals.alert(title: "Could not save colors", info: error.localizedDescription, style: .critical)
                }
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

