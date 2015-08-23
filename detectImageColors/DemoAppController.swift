//  DEMO APP

//  SWIFT 2

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
    var shouldUpdateColorNames = false
    
    var cache = [String:Int]()

    private func updateColorCandidates() {
        spinner.startAnimation(nil)
        colorsFromImage.getColors { (candidates) -> Void in
            self.colorCandidates = candidates
        }
    }

    func updateColorCandidates(notification: NSNotification) {
        if let info = notification.userInfo as? [String:Bool], let boo = info["mouseUp"] {
            shouldUpdateColorNames = boo
        }
        updateColorCandidates()
    }

    override func awakeFromNib() {
        do {
            try initColorNamesFile()
            guard let elton = NSImage(named: "elton") else { throw DemoAppError.CouldNotLoadDemoImage }
            analyseImageAndSetImageView(elton)
        } catch let demoAppError as DemoAppError {
            print(demoAppError.rawValue)
        } catch {
            print(error)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorCandidates:", name: "updateColorCandidatesOK", object: nil)
    }
    
    private func initColorNamesFile() throws {
        guard let jpath = getJSONFilePath() else { throw DemoAppError.InvalidFilePath }
        if NSFileManager().fileExistsAtPath(jpath) {
            try getNamedColorsFromFile(jpath)
        } else {
            guard let bpath = NSBundle.mainBundle().pathForResource("colors_dic", ofType: "json") else {
                throw DemoAppError.InvalidFilePath
            }
            try getNamedColorsFromFile(bpath)
        }
    }

    func updateImage(notification: NSNotification) {
        if let dic = notification.userInfo as? [String: NSImage], let img = dic["image"] {
            analyseImageAndSetImageView(img)
        }
    }

    private func analyseImageAndSetImageView(image: NSImage) {
        shouldUpdateColorNames = true
        imageView.image = image
        colorCandidates = colorsFromImage.getColorsFromImage(image)
    }

    private func refreshWindowElements() {
        if let cols = colorCandidates {
            do {
                guard let bg = cols.background,
                    prim = cols.primary,
                    sec = cols.secondary,
                    det = cols.detail
                    else { throw DemoAppError.ColorDetectorFailed
                }
                
                guard let bgCSS = bg.componentsCSS()?.css,
                    primCSS = prim.componentsCSS()?.css,
                    secCSS = sec.componentsCSS()?.css,
                    detCSS = det.componentsCSS()?.css
                    else { throw DemoAppError.ColorDetectorFailed
                }

                spinner.startAnimation(nil)
                
                primaryColorView.backgroundColorLabel.textColor = bg
                secondaryColorView.backgroundColorLabel.textColor = bg
                detailColorView.backgroundColorLabel.textColor = bg
                
                primaryColorView.color = prim
                secondaryColorView.color = sec
                detailColorView.color = det
                
                primaryColorLabel.textColor = prim
                secondaryColorLabel.textColor = sec
                detailColorLabel.textColor = det
                
                primaryColorNameLabel.textColor = prim
                secondaryColorNameLabel.textColor = sec
                detailColorNameLabel.textColor = det
                
                primaryColorLabel.stringValue = primCSS
                secondaryColorLabel.stringValue = secCSS
                detailColorLabel.stringValue = detCSS
                
                backgroundView.colorCandidates = cols
                
                showOverlay()
                
                if let match = namedColors[bgCSS] {
                    updateBGColorLabels(bgCSS + " " + match)
                } else {
                    if shouldUpdateColorNames {
                        // Basic request cache to avoid launching the same request several times before the first one finishes
                        if cache[bgCSS] == nil {
                            cache[bgCSS] = 1
                            downloader.getColorNameFromAPI(bg) { name in
                                self.updateBGColorLabels(bgCSS + " " + name)
                                self.namedColors[bgCSS] = name
                            }
                        } else {
                            cache[bgCSS]!++
                        }
                    }
                }
                
                if let match = namedColors[primCSS] {
                    primaryColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[primCSS] == nil {
                            cache[primCSS] = 1
                            downloader.getColorNameFromAPI(prim) { name in
                                self.primaryColorNameLabel.stringValue = name
                                self.namedColors[primCSS] = name
                            }
                        } else {
                            cache[primCSS]!++
                        }
                    }
                }
                
                if let match = namedColors[secCSS] {
                    secondaryColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[secCSS] == nil {
                            cache[secCSS] = 1
                            downloader.getColorNameFromAPI(sec) { name in
                                self.secondaryColorNameLabel.stringValue = name
                                self.namedColors[secCSS] = name
                            }
                        } else {
                            cache[secCSS]!++
                        }
                    }
                }
                
                if let match = namedColors[detCSS] {
                    detailColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[detCSS] == nil {
                            cache[detCSS] = 1
                            downloader.getColorNameFromAPI(det) { name in
                                self.detailColorNameLabel.stringValue = name
                                self.namedColors[detCSS] = name
                            }
                        } else {
                            cache[detCSS]!++
                        }
                    }
                }
                
                spinner.stopAnimation(nil)
                window.display()
                
            } catch let demoAppError as DemoAppError {
                print(demoAppError.rawValue)
            } catch {
                print(error)
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

    @IBAction func managePresets(sender: NSButton) {
        window.beginSheet(presetsPanel, completionHandler: nil)
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
        guard let _ = colorCandidates else { return }  // shouldn't be nil, but let's be sure
        showOverlayButton.hidden = true
        if let png = backgroundView.makePNGFromView() {
            ExportColors.savePNGFile(png)
        }
        showOverlayButton.hidden = false
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

    private func getNamedColorsFromFile(path: String) throws {
        guard let data = NSData(contentsOfFile: path),
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:String]
            else { throw DemoAppError.CouldNotLoadColorNamesFile }
        namedColors = json
    }

    func getJSONFilePath() -> String? {
        guard let dirs:[NSString] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) where !dirs.isEmpty else { return nil }
        return dirs[0].stringByAppendingPathComponent("colors_dic.json")
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
    @IBOutlet weak var presetsPanel: NSPanel!

}











