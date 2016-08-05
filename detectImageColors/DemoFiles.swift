// DEMO APP

import Cocoa

class FilesManager {
    
    func selectImageURL() -> URL? {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        dialog.title = "Choose an image"
        dialog.runModal()
        return dialog.url
    }
    
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
        guard let dirs:[NSString] = NSSearchPathForDirectoriesInDomains(d, m, true), !dirs.isEmpty else {
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
    
    func save(json: Data) {
        let panel = NSSavePanel()
        panel.title = "Select the destination for the JSON file"
        panel.canCreateDirectories = true
        let epoch = Int(Date.timeIntervalSinceReferenceDate)
        panel.nameFieldStringValue = "colors-\(epoch).json"
        if panel.runModal() == NSOnState {
            if let chosenfile = panel.url {
                try! json.write(to: URL(fileURLWithPath: chosenfile.path), options: [])
            }
        }
    }
    
    func save(png: Data) {
        let panel = NSSavePanel()
        panel.title = "Select the destination for the PNG file"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "colors-\(Int(Date.timeIntervalSinceReferenceDate)).png"
        if panel.runModal() == NSOnState {
            if let chosenfile = panel.url {
                try! png.write(to: URL(fileURLWithPath: chosenfile.path), options: [])
            }
        }
    }
    
    func presetModal() -> (response: NSModalResponse, textField: NSTextField) {
        let al = NSAlert()
        al.messageText = "Choose a preset name"
        al.alertStyle = NSAlertStyle.warning
        al.addButton(withTitle: "Save")
        al.addButton(withTitle: "Cancel")
        let tf = NSTextField(frame: NSMakeRect(0, 0, 300, 24))
        tf.placeholderString = "Description..."
        al.accessoryView = tf
        let mod = al.runModal()
        return (response: mod, textField: tf)
    }
    
    func deleteModal(preset: Preset) -> NSModalResponse {
        let al: NSAlert = NSAlert()
        al.messageText = "Delete this preset?"
        al.informativeText = "Delete preset '\(preset.name)'?"
        al.alertStyle = NSAlertStyle.warning
        al.addButton(withTitle: "Delete")
        al.addButton(withTitle: "Cancel")
        return al.runModal()
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
