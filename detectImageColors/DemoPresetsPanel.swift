//
//  DemoPresetsPanel.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

struct Preset {
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
}

class DemoPresetsPanel: NSPanel, NSTableViewDataSource, NSTableViewDelegate {
    
    var currentPreset: Preset?

    @IBOutlet weak var demoControlsView: DemoControlsView!
    
    @IBAction func cancelPanel(sender: NSButton) {
        self.orderOut(nil)
    }
    
    @IBAction func loadPreset(sender: NSButton) {
        demoControlsView.setSliders(currentPreset)
        self.orderOut(nil)
    }
    
    let defaults: [Preset] = [Preset(name: "Photo contrasted", brightness: 0.1, distinct: 0.5, saturation: 0.2, contrast: 1.2, noise: 1, contrasted: false), Preset(name: "Photo monochrome", brightness: 0.04, distinct: 0.06, saturation: 0.2, contrast: 2.7, noise: 1, contrasted: false), Preset(name: "Photo of fire", brightness: 0.12, distinct: 0.22, saturation: 0.07, contrast: 1.8, noise: 1, contrasted: false), Preset(name: "Photo blurry hard", brightness: 0.3, distinct: 0.79, saturation: 0.09, contrast: 2.5, noise: 1, contrasted: true), Preset(name: "Illustration shades hard", brightness: 0.26, distinct: 0.13, saturation: 0.38, contrast: 1.4, noise: 1, contrasted: true), Preset(name: "Illustration shades soft", brightness: 0.1, distinct: 0.32, saturation: 0.1, contrast: 2, noise: 1, contrasted: false), Preset(name: "Illustration detailed soft", brightness: 0.26, distinct: 0.27, saturation: 0.19, contrast: 2.5, noise: 1, contrasted: false), Preset(name: "Illustration detailed hard", brightness: 0.25, distinct: 0.43, saturation: 0.15, contrast: 2.1, noise: 1, contrasted: true)]
    
    var customPresets = [Preset]()
    
    var allPresets: [Preset] {
        get {
            return defaults + customPresets
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return allPresets.count
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let table = notification.object as? NSTableView {
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
