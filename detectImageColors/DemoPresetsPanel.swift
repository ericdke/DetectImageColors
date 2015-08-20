//
//  DemoPresetsPanel.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

final class Preset: NSObject, NSCoding {
    
    let name: String
    let thresholdFloorBrightness: CGFloat
    let thresholdDistinctColor: CGFloat
    let thresholdMinimumSaturation: CGFloat
    let contrastRatio: CGFloat
    let contrastedCandidates: Bool
    let thresholdNoiseTolerance: Int
    
    init(name: String, brightness: CGFloat, distinct: CGFloat, saturation: CGFloat, contrast: CGFloat, noise: Int, contrasted: Bool) {
        self.name = name
        self.thresholdFloorBrightness = brightness
        self.thresholdDistinctColor = distinct
        self.thresholdMinimumSaturation = saturation
        self.contrastRatio = contrast
        self.thresholdNoiseTolerance = noise
        self.contrastedCandidates = contrasted
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.thresholdFloorBrightness = aDecoder.decodeObjectForKey("thresholdFloorBrightness") as! CGFloat
        self.thresholdDistinctColor = aDecoder.decodeObjectForKey("thresholdDistinctColor") as! CGFloat
        self.thresholdMinimumSaturation = aDecoder.decodeObjectForKey("thresholdMinimumSaturation") as! CGFloat
        self.contrastRatio = aDecoder.decodeObjectForKey("contrastRatio") as! CGFloat
        self.thresholdNoiseTolerance = aDecoder.decodeIntegerForKey("thresholdNoiseTolerance")
        self.contrastedCandidates = aDecoder.decodeBoolForKey("contrastedCandidates")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(thresholdFloorBrightness, forKey: "thresholdFloorBrightness")
        aCoder.encodeObject(thresholdDistinctColor, forKey: "thresholdDistinctColor")
        aCoder.encodeObject(thresholdMinimumSaturation, forKey: "thresholdMinimumSaturation")
        aCoder.encodeObject(contrastRatio, forKey: "contrastRatio")
        aCoder.encodeInteger(thresholdNoiseTolerance, forKey: "thresholdNoiseTolerance")
        aCoder.encodeBool(contrastedCandidates, forKey: "contrastedCandidates")
    }
    
}

class DemoPresetsPanel: NSPanel, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var currentPreset: Preset?

    @IBOutlet weak var demoControlsView: DemoControlsView!
    
    override func awakeFromNib() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "populatePresets:", name: "populatePresetsOK", object: nil)
    }
    
    func populatePresets(notification: NSNotification) {
        if let del = NSApplication.sharedApplication().delegate as? AppDelegate {
            allPresets = del.presets
        }
    }
    
    @IBAction func cancelPanel(sender: NSButton) {
        self.orderOut(nil)
    }
    
    @IBAction func loadPreset(sender: NSButton) {
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
                NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(allPresets), forKey: "allPresets")
            }
        }
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
        if let id = tableColumn?.identifier {
            guard let cell = tableView.makeViewWithIdentifier(id, owner: self) as? NSTableCellView else { return nil }
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
        return nil
    }
    
}
