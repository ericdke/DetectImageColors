//
//  DemoPresetsPanel.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class DemoPresetsPanel: NSPanel, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var currentPreset: Preset?
    var defaultPresetsCount = 0

    @IBOutlet weak var demoControlsView: DemoControlsView!
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self,
                                                 selector: #selector(DemoPresetsPanel.populatePresets(_:)),
                                                 name: Notification.Name(rawValue: "populatePresetsOK"),
                                                 object: nil)
        tableView.doubleAction = #selector(DemoPresetsPanel.tableDoubleClicked(_:))
        tableView.target = self
    }
    
    func tableDoubleClicked(_ sender: NSTableView) {
        currentPreset = allPresets[sender.selectedRow]
        loadPreset(nil)
    }
    
    func populatePresets(_ notification: Notification) {
        if let del = NSApplication.shared().delegate as? AppDelegate {
            defaultPresetsCount = del.defaultPresets.count
            allPresets = del.presets
        }
    }
    
    @IBAction func cancelPanel(_ sender: NSButton) {
        self.orderOut(nil)
    }
    
    @IBAction func loadPreset(_ sender: NSButton?) {
        demoControlsView.setSliders(preset: currentPreset)
        self.orderOut(nil)
    }
    
    @IBAction func savePreset(_ sender: NSButton) {
        let al: NSAlert = NSAlert()
        al.messageText = "Choose a preset name"
        al.alertStyle = NSAlertStyle.warning
        al.addButton(withTitle: "Save")
        al.addButton(withTitle: "Cancel")
        let tf = NSTextField(frame: NSMakeRect(0, 0, 300, 24))
        tf.placeholderString = "Description..."
        al.accessoryView = tf
        let button = al.runModal()
        if button == NSAlertFirstButtonReturn {
            tf.validateEditing()
            if !tf.stringValue.isEmpty {
                let pres = Preset(name: tf.stringValue,
                                  brightness: CDSettings.thresholdFloorBrightness,
                                  distinct: CDSettings.thresholdDistinctColor,
                                  saturation: CDSettings.thresholdMinimumSaturation,
                                  contrast: CDSettings.contrastRatio,
                                  noise: CDSettings.thresholdNoiseTolerance,
                                  contrasted: CDSettings.ensureContrastedColorCandidates)
                allPresets.append(pres)
                tableView.reloadData()
                savePresets()
            }
        }
    }
    
    func savePresets() {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: allPresets),
                                    forKey: "allPresets")
    }
    
    var allPresets = [Preset]()
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [SortDescriptor]) {
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
                    allPresets.sort  { Int($0.contrastedCandidates) < Int($1.contrastedCandidates) }
                } else {
                    allPresets.sort  { Int($0.contrastedCandidates) > Int($1.contrastedCandidates) }
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
    
    override func keyDown(_ theEvent: NSEvent) {
        if theEvent.keyCode == 51 || theEvent.keyCode == 117 {
            if let cp = currentPreset {
                if allPresets[tableView.selectedRow].defaultPreset {
                    Swift.print("ERROR: can't delete default preset")
                } else {
                    let al: NSAlert = NSAlert()
                    al.messageText = "Delete this preset?"
                    al.informativeText = "Delete preset '\(cp.name)'?"
                    al.alertStyle = NSAlertStyle.warning
                    al.addButton(withTitle: "Delete")
                    al.addButton(withTitle: "Cancel")
                    let button = al.runModal()
                    if button == NSAlertFirstButtonReturn {
                        allPresets.remove(at: tableView.selectedRow)
                        tableView.reloadData()
                        savePresets()
                    }
                }
            }
        }
    }
    
    
    
}
