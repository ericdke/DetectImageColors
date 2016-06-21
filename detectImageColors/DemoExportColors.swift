//  DEMO APP

//  SWIFT 2

import Cocoa

class ExportColors {

    class DemoView: NSView {
        var color: NSColor?
        override func draw(_ dirtyRect: NSRect) {
            if let color = self.color {
                color.setFill()
                NSRectFill(dirtyRect)
            }
            super.draw(dirtyRect)
        }
    }

    typealias ExportViews = (background: DemoView, primary: DemoView, secondary: DemoView, detail: DemoView)

    // ---

    class func saveJSONFile(colorCandidates: ColorCandidates) {
        if let dic = toDictionary(colorCandidates: colorCandidates), json = toJSON(dictionary: dic) {
            saveJSONFile(json: json)
        }
    }

    class func savePNGFile(png: Data) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the PNG file"
        myFiledialog.canCreateDirectories = true
        myFiledialog.nameFieldStringValue = "colors-\(Int(Date.timeIntervalSinceReferenceDate)).png"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.url, path = chosenfile.path {
                _ = try? png.write(to: URL(fileURLWithPath: path), options: [])
            }
        }
    }

    class func makeColorView(colorCandidates: ColorCandidates, image: NSImage) -> NSView {
        let mainView = NSView(frame: NSMakeRect(0, 0, 600, 600))
        let imageView = NSImageView(frame: NSMakeRect(150, 250, 300, 300))
        imageView.image = image
        let (background, primary, secondary, detail) = makeDemoViews(willIncludeImage: true)
        let finalView = makeFinalView(colors: colorCandidates, withViews: (background, primary, secondary, detail), toView: mainView)
        finalView.addSubview(imageView)
        return finalView
    }

    class func makeColorView(colorCandidates: ColorCandidates) -> NSView {
        let mainView = NSView(frame: NSMakeRect(0, 0, 800, 200))
        let (background, primary, secondary, detail) = makeDemoViews()
        return makeFinalView(colors: colorCandidates, withViews: (background, primary, secondary, detail), toView: mainView)
    }

    // ---

    private class func makeDemoViews(willIncludeImage: Bool = false) -> ExportViews {
        if willIncludeImage {
            let pv = DemoView(frame: NSMakeRect(100, 50, 100, 150))
            let sv = DemoView(frame: NSMakeRect(250, 50, 100, 150))
            let dv = DemoView(frame: NSMakeRect(400, 50, 100, 150))
            let bv = DemoView(frame: NSMakeRect(0, 0, 600, 600))
            return (background: bv, primary: pv, secondary: sv, detail: dv)
        } else {
            let pv = DemoView(frame: NSMakeRect(0, 0, 200, 200))
            let sv = DemoView(frame: NSMakeRect(200, 0, 200, 200))
            let dv = DemoView(frame: NSMakeRect(400, 0, 200, 200))
            let bv = DemoView(frame: NSMakeRect(600, 0, 200, 200))
            return (background: bv, primary: pv, secondary: sv, detail: dv)
        }
    }

    private class func makeFinalView(colors colorCandidates: ColorCandidates, withViews sourceViews: ExportViews, toView view: NSView) -> NSView {
        let coloredViews = assignColorsToViews(colorCandidates: colorCandidates, views: sourceViews)
        return addColoredViewsToView(views: coloredViews, view: view)
    }

    private class func assignColorsToViews(colorCandidates: ColorCandidates, views: ExportViews) -> ExportViews {
        views.primary.color = colorCandidates.primary
        views.secondary.color = colorCandidates.secondary
        views.detail.color = colorCandidates.detail
        views.background.color = colorCandidates.background
        return views
    }

    private class func addColoredViewsToView(views: ExportViews, view: NSView) -> NSView {
        view.addSubview(views.background)
        view.addSubview(views.primary)
        view.addSubview(views.secondary)
        view.addSubview(views.detail)
        return view
    }

    private class func toDictionary(colorCandidates: ColorCandidates) -> [String:[String:AnyObject]]? {
        guard let primary = getRGBSpaceName(color: colorCandidates.primary), let alternative = getRGBSpaceName(color: colorCandidates.secondary), let detail = getRGBSpaceName(color: colorCandidates.detail), let background = getRGBSpaceName(color: colorCandidates.background) else { return nil }
        var dic = [String:[String:AnyObject]]()
        dic["main"] = getDictionaryColorComponents(color: primary)
        dic["alternative"] = getDictionaryColorComponents(color: alternative)
        dic["detail"] = getDictionaryColorComponents(color: detail)
        dic["background"] = getDictionaryColorComponents(color: background)
        dic["settings"] = getDictionarySettings()
        return dic
    }

    private class func getRGBSpaceName(color: NSColor?) -> NSColor? {
        guard let thisColor = color, let rgbColor = thisColor.usingColorSpaceName(NSCalibratedRGBColorSpace) else { return nil }
        return rgbColor
    }

    private class func getDictionaryColorComponents(color: NSColor) -> [String:AnyObject] {
        return ["red": color.redComponent, "green": color.greenComponent, "blue": color.blueComponent, "css": color.componentsCSS()!.css]
    }

    private class func getDictionarySettings() -> [String:AnyObject] {
        return ["EnsureContrastedColorCandidates": CDSettings.EnsureContrastedColorCandidates, "ThresholdDistinctColor": CDSettings.ThresholdDistinctColor, "ContrastRatio": CDSettings.ContrastRatio, "ThresholdNoiseTolerance": CDSettings.ThresholdNoiseTolerance, "ThresholdFloorBrightness": CDSettings.ThresholdFloorBrightness, "ThresholdMinimumSaturation": CDSettings.ThresholdMinimumSaturation]
    }

    private class func toJSON(colorCandidates: ColorCandidates) -> Data? {
        guard let dic = toDictionary(colorCandidates: colorCandidates) else { return nil }
        return toJSON(dictionary: dic)
    }

    private class func toJSON(dictionary: [String:[String:AnyObject]]) -> Data? {
        do {
            let json = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            return json
        } catch {
            print(error)
            return nil
        }
    }

    private class func saveJSONFile(json: Data) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the JSON file"
        myFiledialog.canCreateDirectories = true
        let epoch = Int(Date.timeIntervalSinceReferenceDate)
        myFiledialog.nameFieldStringValue = "colors-\(epoch).json"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.url, path = chosenfile.path {
                _ = try? json.write(to: URL(fileURLWithPath: path), options: [])
            }
        }
    }

    private class func trashFile(path: String) {
        do {
            try FileManager.default().removeItem(atPath: path)
        } catch {
            print(error)
        }
    }

}


