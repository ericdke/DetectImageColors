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

    class func saveJSONFile(colors: ColorCandidates) {
        saveJSONFile(json: colors.toJSONData())
    }

    class func savePNGFile(data: Data) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the PNG file"
        myFiledialog.canCreateDirectories = true
        myFiledialog.nameFieldStringValue = "colors-\(Int(Date.timeIntervalSinceReferenceDate)).png"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.url, path = chosenfile.path {
                try! data.write(to: URL(fileURLWithPath: path), options: [])
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

    private class func saveJSONFile(json: Data) {
        let myFiledialog: NSSavePanel = NSSavePanel()
        myFiledialog.title = "Select the destination for the JSON file"
        myFiledialog.canCreateDirectories = true
        let epoch = Int(Date.timeIntervalSinceReferenceDate)
        myFiledialog.nameFieldStringValue = "colors-\(epoch).json"
        if myFiledialog.runModal() == NSOnState {
            if let chosenfile = myFiledialog.url, path = chosenfile.path {
                try! json.write(to: URL(fileURLWithPath: path), options: [])
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


