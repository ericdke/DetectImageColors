//  DEMO APP

//  SWIFT 2

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var appController: AppController!
    
    var presets = [Preset]()
    var defaultPresets = [Preset]()

    func applicationWillFinishLaunching(_ notification: Notification) {
        window.setFrameUsingName("DetectImageColorsDemo")
        window.title = "DetectImageColors"
        window.backgroundColor = NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        let bundle = Bundle.main()
        do {
            if let apPath = bundle.pathForResource("defaultPresets", ofType: "json"), let apData = try? Data(contentsOf: URL(fileURLWithPath: apPath)), let apJSON = try JSONSerialization.jsonObject(with: apData, options: []) as? [[String:AnyObject]] {
                for pres in apJSON {
                    let p = Preset(name: pres["name"] as! String, brightness: pres["brightness"] as! CGFloat, distinct: pres["distinct"] as! CGFloat, saturation: pres["saturation"] as! CGFloat, contrast: pres["contrast"] as! CGFloat, noise: pres["noise"] as! Int, contrasted: pres["contrasted"] as! Bool, defaultPreset: pres["defaultPreset"] as! Bool)
                    defaultPresets.append(p)
                }
            }
        } catch {
            print(error)
            fatalError()
        }
        UserDefaults.standard().set(getDefaultSettings(), forKey: "defaultSettings")
        if let data = UserDefaults.standard().object(forKey: "allPresets") as? Data,
            let presets = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Preset] {
            self.presets = presets
        } else {
            self.presets = defaultPresets.sorted { $0.name < $1.name }
        }
        NotificationCenter.default().post(name: Notification.Name(rawValue: "populatePresetsOK"), object: nil, userInfo: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        window.saveFrame(usingName: "DetectImageColorsDemo")
        saveNamedColors()
    }

    private func saveNamedColors() {
        if let path = appController.getJSONFilePath() {
            do {
                let enc = try JSONSerialization.data(withJSONObject: appController.namedColors, options: .prettyPrinted)
                let written = (try? enc.write(to: URL(fileURLWithPath: path), options: [])) != nil
                if !written { throw DemoAppError.CouldNotSaveColorNamesFile }
            } catch let demoAppError as DemoAppError {
                print(demoAppError.rawValue)
            } catch {
                print(error)
            }
        }
    }

    private func getDefaultSettings() -> NSDictionary {
        return ["ThresholdDistinctColor": CDSettings.thresholdDistinctColor, "ThresholdNoiseTolerance": CDSettings.thresholdNoiseTolerance, "ThresholdMinimumSaturation": CDSettings.thresholdMinimumSaturation, "ThresholdFloorBrightness": CDSettings.thresholdFloorBrightness, "ContrastRatio": CDSettings.contrastRatio]
    }

}

