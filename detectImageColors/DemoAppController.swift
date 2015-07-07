//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    var colorsFromImage = ColorsFromImage()
    var namedColors = [String:String]()
    let downloader = Downloader()
    var colorCandidates: ColorCandidates? {
        didSet {
            spinner.stopAnimation(nil)
            refreshWindowElements()
        }
    }

    private func updateColorCandidates() {
        spinner.startAnimation(nil)
        colorsFromImage.getColors { (candidates) -> Void in
            self.colorCandidates = candidates
        }
    }

    func updateColorCandidates(notification: NSNotification) {
        updateColorCandidates()
    }

    override func awakeFromNib() {
        if let path = getJSONFilePath() {
            if NSFileManager().fileExistsAtPath(path) {
                getNamedColorsFromFile(path)
            } else {
                if let path = NSBundle.mainBundle().pathForResource("colors_dic", ofType: "json") {
                    getNamedColorsFromFile(path)
                }
            }
        }
        analyseImageAndSetImageView(NSImage(named: "elton")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorCandidates:", name: "updateColorCandidatesOK", object: nil)

        // ---

//        let resized = colorsFromImage.colorDetector.resize(NSImage(named: "elton")!)!
//        let imageRep = resized.representations.last as! NSBitmapImageRep
//        let testColorsBytes = colorsFromImage.colorDetector.mainColorsFromImageBytes(600, imageRep: imageRep, limitedNumberOfColors: false)

//        println(testColorsBytes.count) // 186349
//
//        var bigColors = [(UInt32, Int)]()
//        let max = 500
//        if testColorsBytes.count > max {
//            for cb in testColorsBytes[0...max] {
//                bigColors.append(cb)
//            }
//        }
//
//        let testColors = colorsFromImage.colorDetector.colorsFromColorBytes(bigColors)
//
//        println(testColors)
        // ---
    }

    func updateImage(notification: NSNotification) {
        if let dic = notification.userInfo as? [String: NSImage], let img = dic["image"] {
            analyseImageAndSetImageView(img)
        }
    }

    private func analyseImageAndSetImageView(image: NSImage) {
        imageView.image = image
        colorCandidates = colorsFromImage.getColorsFromImage(image)
    }

    private func refreshWindowElements() {
        if let cols = colorCandidates {

            let bgCSS = cols.background!.componentsCSS()!.css
            let primCSS = cols.primary!.componentsCSS()!.css
            let secCSS = cols.secondary!.componentsCSS()!.css
            let detCSS = cols.detail!.componentsCSS()!.css

            primaryColorView.backgroundColorLabel.textColor = cols.background
            secondaryColorView.backgroundColorLabel.textColor = cols.background
            detailColorView.backgroundColorLabel.textColor = cols.background

            primaryColorView.color = cols.primary
            secondaryColorView.color = cols.secondary
            detailColorView.color = cols.detail

            primaryColorLabel.textColor = cols.primary
            secondaryColorLabel.textColor = cols.secondary
            detailColorLabel.textColor = cols.detail

            primaryColorNameLabel.textColor = cols.primary
            secondaryColorNameLabel.textColor = cols.secondary
            detailColorNameLabel.textColor = cols.detail

            primaryColorLabel.stringValue = primCSS
            secondaryColorLabel.stringValue = secCSS
            detailColorLabel.stringValue = detCSS

            backgroundView.colorCandidates = cols

            showOverlay()

            if let match = namedColors[bgCSS] {
                updateBGColorLabels(bgCSS + " " + match)
            } else {
                downloader.getColorNameFromAPI(cols.background!, completionHandler: { (name) -> Void in
                    self.updateBGColorLabels(bgCSS + " " + name)
                    self.namedColors[bgCSS] = name
                })
            }
            if let match = namedColors[primCSS] {
                primaryColorNameLabel.stringValue = match
            } else {
                downloader.getColorNameFromAPI(cols.primary!, completionHandler: { (name) -> Void in
                    self.primaryColorNameLabel.stringValue = name
                    self.namedColors[primCSS] = name
                })
            }
            if let match = namedColors[secCSS] {
                secondaryColorNameLabel.stringValue = match
            } else {
                downloader.getColorNameFromAPI(cols.secondary!, completionHandler: { (name) -> Void in
                    self.secondaryColorNameLabel.stringValue = name
                    self.namedColors[secCSS] = name
                })
            }
            if let match = namedColors[detCSS] {
                detailColorNameLabel.stringValue = match
            } else {
                downloader.getColorNameFromAPI(cols.detail!, completionHandler: { (name) -> Void in
                    self.detailColorNameLabel.stringValue = name
                    self.namedColors[detCSS] = name
                })
            }

        }
    }

    private func updateBGColorLabels(str: String) {
        primaryColorView.backgroundColorLabel.stringValue = str
        secondaryColorView.backgroundColorLabel.stringValue = str
        detailColorView.backgroundColorLabel.stringValue = str
    }

    @IBAction func showOverlayClicked(sender: NSButton) {
        showOverlay()
    }

    private func showOverlay() {
        if showOverlayButton.state == NSOnState {
            imageView.primaryDemoColorView.color = colorCandidates!.primary!.colorWithAlphaComponent(0.9)
            imageView.secondaryDemoColorView.color = colorCandidates!.secondary!.colorWithAlphaComponent(0.9)
            imageView.detailDemoColorView.color = colorCandidates!.detail!.colorWithAlphaComponent(0.9)
            imageView.backgroundDemoColorView.color = colorCandidates!.background!.colorWithAlphaComponent(0.9)
        } else {
            imageView.primaryDemoColorView.color = nil
            imageView.secondaryDemoColorView.color = nil
            imageView.detailDemoColorView.color = nil
            imageView.backgroundDemoColorView.color = nil
        }
    }


    @IBAction func exportColorsToJSON(sender: NSMenuItem) {
        if let cols = colorCandidates {
            ExportColors.saveJSONFile(cols)
        }
    }

    @IBAction func exportColorsToPNG(sender: NSMenuItem) {
//        if let cols = colorCandidates, img = imageView.image {
//            let v = ExportColors.makeColorView(cols, image: img)
//            if let png = ExportColors.makePNGFromView(v) {
//                ExportColors.savePNGFile(png)
//            }
//        }
        if let _ = colorCandidates {
            showOverlayButton.hidden = true
            if let png = ExportColors.makePNGFromView(backgroundView) {
                ExportColors.savePNGFile(png)
            }
            showOverlayButton.hidden = false
        }
    }

    @IBAction func openImageFile(sender: NSMenuItem) {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        dialog.title = "Choose an image"
        dialog.runModal()
        if let chosenfile = dialog.URL, path = chosenfile.path, img = NSImage(contentsOfFile: path) {
            analyseImageAndSetImageView(img)
        }
    }

    private func getNamedColorsFromFile(path: String) {
        do {
            let data = NSData(contentsOfFile: path)
            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! [String:String]
            namedColors = json
        } catch let error {
            print(error)
        }
        
    }

    func getJSONFilePath() -> String? {
        if let dirs:[String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)  {
            return dirs[0].stringByAppendingPathComponent("colors_dic.json")
        }
        return nil
    }

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var imageView: DemoImageView!
    @IBOutlet weak var backgroundView: DemoBackgroundView!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var primaryColorView: DemoColorView!
    @IBOutlet weak var secondaryColorView: DemoColorView!
    @IBOutlet weak var detailColorView: DemoColorView!
    @IBOutlet weak var primaryColorLabel: NSTextField!
    @IBOutlet weak var secondaryColorLabel: NSTextField!
    @IBOutlet weak var detailColorLabel: NSTextField!
    @IBOutlet weak var showOverlayButton: NSButton!
    @IBOutlet weak var primaryColorNameLabel: NSTextField!
    @IBOutlet weak var secondaryColorNameLabel: NSTextField!
    @IBOutlet weak var detailColorNameLabel: NSTextField!

}











