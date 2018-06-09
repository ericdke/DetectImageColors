// DEMO APP

import Cocoa

class FilesManager {

    func namedColorsFromFile(path: String) throws -> [String:String] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
            else {
                throw DemoAppError.couldNotLoadColorNamesFile
        }
        return json
    }
    
    func getJSONFilePath() -> String? {
        let d = FileManager.SearchPathDirectory.documentDirectory
        let m = FileManager.SearchPathDomainMask.allDomainsMask
        let dirs = NSSearchPathForDirectoriesInDomains(d, m, true).compactMap { $0 as NSString }
        guard !dirs.isEmpty else {
            return nil
        }
        return dirs[0].appendingPathComponent("colors_dic.json")
    }
    
    func saveColorNamesFile(data: Data, path: String) throws {
        let written = (try? data.write(to: URL(fileURLWithPath: path), options: [])) != nil
        if !written { throw DemoAppError.couldNotSaveColorNamesFile }
    }
    
    func fileExists(at path: String) -> Bool {
        return FileManager().fileExists(atPath: path)
    }
    
    func save(defaultSettings: NSDictionary) {
        UserDefaults.standard.set(defaultSettings, forKey: "defaultSettings")
    }
    
    func save(presets: [Preset]) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: presets),
                                  forKey: "allPresets")
    }

    var defaultPresetsPath: String? {
        return Bundle.main.path(forResource: "defaultPresets", ofType: "json")
    }
    
    var colorsPath: String? {
        return Bundle.main.path(forResource: "colors_dic", ofType: "json")
    }
    
    var allPresets: [Preset] {
        if let data = UserDefaults.standard.object(forKey: "allPresets") as? Data,
            let presets = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Preset] {
            return presets
        }
        return []
    }
    
    var defaultPresetsData: Data? {
        if let apPath = defaultPresetsPath {
            return try? Data(contentsOf: URL(fileURLWithPath: apPath))
        }
        return nil
    }
}
