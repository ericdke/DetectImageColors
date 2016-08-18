// DEMO APP

import Cocoa

class DemoPresetsPanel: NSPanel, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var currentPreset: Preset?
    var defaultPresetsCount = 0
    let filesManager = FilesManager()

    @IBOutlet weak var demoControlsView: DemoControlsView!
    
    override func awakeFromNib() {
        tableView.doubleAction = #selector(tableDoubleClicked(_:))
        tableView.target = self
    }
    
    func tableDoubleClicked(_ sender: NSTableView) {
        currentPreset = allPresets[sender.selectedRow]
        loadPreset(nil)
    }
    
    func populatePresets(def: [Preset], all: [Preset]) {
        defaultPresetsCount = def.count
        allPresets = all
    }
    
    @IBAction func cancelPanel(_ sender: NSButton) {
        self.orderOut(nil)
    }
    
    @IBAction func loadPreset(_ sender: NSButton?) {
        demoControlsView.setSliders(preset: currentPreset)
        self.orderOut(nil)
    }
    
    @IBAction func savePreset(_ sender: NSButton) {
        let mod = filesManager.presetModal()
        if mod.response == NSAlertFirstButtonReturn {
            mod.textField.validateEditing()
            if !mod.textField.stringValue.isEmpty {
                let pres = Preset(name: mod.textField.stringValue,
                                  brightness: CDSettings.thresholdFloorBrightness,
                                  distinct: CDSettings.thresholdDistinctColor,
                                  saturation: CDSettings.thresholdMinimumSaturation,
                                  contrast: CDSettings.contrastRatio,
                                  noise: CDSettings.thresholdNoiseTolerance,
                                  contrasted: CDSettings.ensureContrastedColorCandidates)
                allPresets.append(pres)
                tableView.reloadData()
                filesManager.save(presets: allPresets)
            }
        }
    }
    
    var allPresets = [Preset]()
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        if let descriptor = tableView.sortDescriptors.first,
            let key = descriptor.key {
            switch key {
            case "Name":
                if descriptor.ascending {
                    allPresets.sort  { $0.name < $1.name }
                } else {
                    allPresets.sort  { $0.name > $1.name }
                }
            case "TDC":
                if descriptor.ascending {
                    allPresets.sort  { $0.thresholdDistinctColor < $1.thresholdDistinctColor }
                } else {
                    allPresets.sort  { $0.thresholdDistinctColor > $1.thresholdDistinctColor }
                }
            case "CR":
                if descriptor.ascending {
                    allPresets.sort  { $0.contrastRatio < $1.contrastRatio }
                } else {
                    allPresets.sort  { $0.contrastRatio > $1.contrastRatio }
                }
            case "NT":
                if descriptor.ascending {
                    allPresets.sort  { $0.thresholdNoiseTolerance < $1.thresholdNoiseTolerance }
                } else {
                    allPresets.sort  { $0.thresholdNoiseTolerance > $1.thresholdNoiseTolerance }
                }
            case "TFB":
                if descriptor.ascending {
                    allPresets.sort  { $0.thresholdFloorBrightness < $1.thresholdFloorBrightness }
                } else {
                    allPresets.sort  { $0.thresholdFloorBrightness > $1.thresholdFloorBrightness }
                }
            case "TMS":
                if descriptor.ascending {
                    allPresets.sort  { $0.thresholdMinimumSaturation < $1.thresholdMinimumSaturation }
                } else {
                    allPresets.sort  { $0.thresholdMinimumSaturation > $1.thresholdMinimumSaturation }
                }
            case "ECCC":
                if descriptor.ascending {
                    allPresets.sort  { (a, b) in
                        let boolIntA = a.contrastedCandidates ? 1 : 0
                        let boolIntB = b.contrastedCandidates ? 1 : 0
                        return boolIntA < boolIntB
                    }
                } else {
                    allPresets.sort  { (a, b) in
                        let boolIntA = a.contrastedCandidates ? 1 : 0
                        let boolIntB = b.contrastedCandidates ? 1 : 0
                        return boolIntA < boolIntB
                    }
                }
            default:
                Swift.print("Error with tableview header")
            }
            tableView.reloadData()
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        currentPreset = nil
        if let table = notification.object as? NSTableView, table.selectedRow != -1 {
            currentPreset = allPresets[table.selectedRow]
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier,
            let cell = tableView.make(withIdentifier: id, owner: self) as? NSTableCellView else {
                return nil
        }
        let preset = allPresets[row]
        if id == "mainColumn" {
            cell.textField?.stringValue = preset.name.capitalized
        } else if id == "TDCColumn" {
            cell.textField?.stringValue = String(format: "%.2f", arguments: [preset.thresholdDistinctColor])
        } else if id == "CRColumn" {
            cell.textField?.stringValue = String(format: "%.2f", arguments: [preset.contrastRatio])
        } else if id == "NTColumn" {
            cell.textField?.integerValue = preset.thresholdNoiseTolerance
        } else if id == "TFBColumn" {
            cell.textField?.stringValue = String(format: "%.2f", arguments: [preset.thresholdFloorBrightness])
        } else if id == "TMSColumn" {
            cell.textField?.stringValue = String(format: "%.2f", arguments: [preset.thresholdFloorBrightness])
        } else if id == "ECCCColumn" {
            cell.textField?.stringValue = preset.contrastedCandidates ?  "Yes" : "No"
        }
        return cell
    }
    
    override func keyDown(with theEvent: NSEvent) {
        if theEvent.keyCode == 51 || theEvent.keyCode == 117 {
            if let cp = currentPreset {
                if allPresets[tableView.selectedRow].defaultPreset {
                    Swift.print("ERROR: can't delete default preset")
                } else {
                    if filesManager.deleteModal(preset: cp) == NSAlertFirstButtonReturn {
                        allPresets.remove(at: tableView.selectedRow)
                        tableView.reloadData()
                        filesManager.save(presets: allPresets)
                    }
                }
            }
        }
    }
    
    
    
}
