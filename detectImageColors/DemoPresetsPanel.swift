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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populatePresets:", name: "populatePresetsOK", object: nil)
        tableView.doubleAction = Selector("tableDoubleClicked:")
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
        } else {
            let br = String(format: "%.2f", arguments: [preset.thresholdFloorBrightness])
            let dis = String(format: "%.2f", arguments: [preset.thresholdDistinctColor])
            let sat = String(format: "%.2f", arguments: [preset.thresholdMinimumSaturation])
            let rat = String(format: "%.2f", arguments: [preset.contrastRatio])
            let noise = preset.thresholdNoiseTolerance
            let con = preset.contrastedCandidates ?  "Yes" : "No"
            cell.textField?.stringValue = "TDC:\(dis) CR:\(rat) NT:\(noise) TFB:\(br) TMS:\(sat) ECCC:\(con)"
        }
        return cell
    }
    
    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 51 || theEvent.keyCode == 117 {
            if let cp = currentPreset {
                if tableView.selectedRow < defaultPresetsCount {
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
