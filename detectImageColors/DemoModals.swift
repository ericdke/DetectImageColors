//
//  DemoModals.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 28/09/2017.
//  Copyright © 2017 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class Modals {
    
    static func save(json: Data) {
        let panel = NSSavePanel()
        panel.title = "Select the destination for the JSON file"
        panel.canCreateDirectories = true
        let epoch = Int(Date.timeIntervalSinceReferenceDate)
        panel.nameFieldStringValue = "colors-\(epoch).json"
        if panel.runModal() == .OK {
            if let chosenfile = panel.url {
                try! json.write(to: URL(fileURLWithPath: chosenfile.path), options: [])
            }
        }
    }
    
    static func save(png: Data) {
        let panel = NSSavePanel()
        panel.title = "Select the destination for the PNG file"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "colors-\(Int(Date.timeIntervalSinceReferenceDate)).png"
        if panel.runModal() == .OK {
            if let chosenfile = panel.url {
                try! png.write(to: URL(fileURLWithPath: chosenfile.path), options: [])
            }
        }
    }
    
    static func presetModal() -> (response: NSApplication.ModalResponse, textField: NSTextField) {
        let al = NSAlert()
        al.messageText = "Choose a preset name"
        al.alertStyle = NSAlert.Style.warning
        al.addButton(withTitle: "Save")
        al.addButton(withTitle: "Cancel")
        let tf = NSTextField(frame: NSMakeRect(0, 0, 300, 24))
        tf.placeholderString = "Description..."
        al.accessoryView = tf
        let mod = al.runModal()
        return (response: mod, textField: tf)
    }
    
    static func deleteModal(preset: Preset) -> NSApplication.ModalResponse {
        let al: NSAlert = NSAlert()
        al.messageText = "Delete this preset?"
        al.informativeText = "Delete preset '\(preset.name)'?"
        al.alertStyle = NSAlert.Style.warning
        al.addButton(withTitle: "Delete")
        al.addButton(withTitle: "Cancel")
        return al.runModal()
    }
    
    static func selectImageURL() -> URL? {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        dialog.title = "Choose an image"
        dialog.runModal()
        return dialog.url
    }
    
    static func alert(title: String, info: String?, style: NSAlert.Style = .warning) {
        let al = NSAlert()
        al.messageText = title
        if let info = info {
            al.informativeText = info
        }
        al.alertStyle = style
        al.runModal()
    }
    
}
