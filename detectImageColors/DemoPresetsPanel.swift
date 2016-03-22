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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DemoPresetsPanel.populatePresets(_:)), name: "populatePresetsOK", object: nil)
        tableView.doubleAction = #selector(DemoPresetsPanel.tableDoubleClicked(_:))
        tableView.target = self
    }
    
    func tableDoubleClicked(sender: NSTableView) {
        currentPreset = allPresets[sender.selectedRow]
        loadPreset(nil)
    }
    
    func populatePresets(notification: NSNotification) {
        if let del = NSApplication.sharedApplication().delegate as? AppDelegate {
            defaultPresetsCount = del.defaultPresets.count
            allPresets = del.presets
        }
    }
    
    @IBAction func cancelPanel(sender: NSButton) {
        self.orderOut(nil)
    }
    
    @IBAction func loadPreset(sender: NSButton?) {
        demoControlsView.setSliders(currentPreset)
        self.orderOut(nil)
    }
    
    @IBAction func savePreset(sender: NSButton) {
        let al: NSAlert = NSAlert()
        al.messageText = "Choose a preset name"
        al.alertStyle = NSAlertStyle.WarningAlertStyle
        al.addButtonWithTitle("Save")
        al.addButtonWithTitle("Cancel")
        let tf = NSTextField(frame: NSMakeRect(0, 0, 300, 24))
        tf.placeholderString = "Description..."
        al.accessoryView = tf
        let button = al.runModal()
        if button == NSAlertFirstButtonReturn {
            tf.validateEditing()
            if !tf.stringValue.isEmpty {
                let pres = Preset(name: tf.stringValue, brightness: CDSettings.ThresholdFloorBrightness, distinct: CDSettings.ThresholdDistinctColor, saturation: CDSettings.ThresholdMinimumSaturation, contrast: CDSettings.ContrastRatio, noise: CDSettings.ThresholdNoiseTolerance, contrasted: CDSettings.EnsureContrastedColorCandidates)
                allPresets.append(pres)
                tableView.reloadData()
                savePresets()
            }
        }
    }
    
    func savePresets() {
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(allPresets), forKey: "allPresets")
    }
    
    var allPresets = [Preset]()
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        if let descriptor = tableView.sortDescriptors.first, let key = descriptor.key {
            switch key {
            case "Name":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.name < $1.name })
                } else {
                    allPresets.sortInPlace({ $0.name > $1.name })
                }
            case "TDC":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.thresholdDistinctColor < $1.thresholdDistinctColor })
                } else {
                    allPresets.sortInPlace({ $0.thresholdDistinctColor > $1.thresholdDistinctColor })
                }
            case "CR":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.contrastRatio < $1.contrastRatio })
                } else {
                    allPresets.sortInPlace({ $0.contrastRatio > $1.contrastRatio })
                }
            case "NT":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.thresholdNoiseTolerance < $1.thresholdNoiseTolerance })
                } else {
                    allPresets.sortInPlace({ $0.thresholdNoiseTolerance > $1.thresholdNoiseTolerance })
                }
            case "TFB":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.thresholdFloorBrightness < $1.thresholdFloorBrightness })
                } else {
                    allPresets.sortInPlace({ $0.thresholdFloorBrightness > $1.thresholdFloorBrightness })
                }
            case "TMS":
                if descriptor.ascending {
                    allPresets.sortInPlace({ $0.thresholdMinimumSaturation < $1.thresholdMinimumSaturation })
                } else {
                    allPresets.sortInPlace({ $0.thresholdMinimumSaturation > $1.thresholdMinimumSaturation })
                }
            case "ECCC":
                if descriptor.ascending {
                    allPresets.sortInPlace({ Int($0.contrastedCandidates) < Int($1.contrastedCandidates) })
                } else {
                    allPresets.sortInPlace({ Int($0.contrastedCandidates) > Int($1.contrastedCandidates) })
                }
            default:
                Swift.print("Error with tableview header")
            }
            tableView.reloadData()
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return allPresets.count
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        currentPreset = nil
        if let table = notification.object as? NSTableView where table.selectedRow != -1 {
            currentPreset = allPresets[table.selectedRow]
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier, let cell = tableView.makeViewWithIdentifier(id, owner: self) as? NSTableCellView else { return nil }
        let preset = allPresets[row]
        if id == "mainColumn" {
            cell.textField?.stringValue = preset.name.capitalizedString
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
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 51 || theEvent.keyCode == 117 {
            if let cp = currentPreset {
                if allPresets[tableView.selectedRow].defaultPreset {
                    Swift.print("ERROR: can't delete default preset")
                } else {
                    let al: NSAlert = NSAlert()
                    al.messageText = "Delete this preset?"
                    al.informativeText = "Delete preset '\(cp.name)'?"
                    al.alertStyle = NSAlertStyle.WarningAlertStyle
                    al.addButtonWithTitle("Delete")
                    al.addButtonWithTitle("Cancel")
                    let button = al.runModal()
                    if button == NSAlertFirstButtonReturn {
                        allPresets.removeAtIndex(tableView.selectedRow)
                        tableView.reloadData()
                        savePresets()
                    }
                }
            }
        }
    }
    
    
    
}
