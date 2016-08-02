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

    func updateColorCandidates(notification: Notification) {
        // FIXME: crap system, should be refactored
        if let info = (notification as NSNotification).userInfo as? [String:Bool],
            let boo = info["mouseUp"] {
            shouldUpdateColorNames = boo
        }
        updateColorCandidates()
    }

    override func awakeFromNib() {
        do {
            try initColorNamesFile()
            guard let elton = NSImage(named: "elton") else {
                throw DemoAppError.couldNotLoadDemoImage
            }
            analyseImageAndSetImageView(with: elton)
        } catch let demoAppError as DemoAppError {
            print(demoAppError.rawValue)
        } catch {
            print(error)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppController.updateImage(_:)), name: Notification.Name(rawValue: "updateImageByDropOK"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppController.updateColorCandidates(notification:)), name: Notification.Name(rawValue: "updateColorCandidatesOK"), object: nil)
    }
    
    private func initColorNamesFile() throws {
        guard let jpath = getJSONFilePath() else {
            throw DemoAppError.invalidFilePath
        }
        if FileManager().fileExists(atPath: jpath) {
            try getNamedColorsFromFile(path: jpath)
        } else {
            guard let bpath = Bundle.main.path(forResource: "colors_dic", ofType: "json") else {
                throw DemoAppError.invalidFilePath
            }
            try getNamedColorsFromFile(path: bpath)
        }
    }

    func updateImage(_ notification: Notification) {
        if let dic = (notification as NSNotification).userInfo as? [String: NSImage],
            let img = dic["image"] {
            analyseImageAndSetImageView(with: img)
        }
    }

    private func analyseImageAndSetImageView(with image: NSImage) {
        colorsFromImage.image = image
        shouldUpdateColorNames = true
        imageView.image = image
        colorCandidates = colorsFromImage.getColors(from: image)
    }

    private func refreshWindowElements() {
        if let cols = colorCandidates {
            do {
                guard let bg = cols.background,
                    let prim = cols.primary,
                    let sec = cols.secondary,
                    let det = cols.detail
                    else {
                        throw DemoAppError.colorDetectorFailed
                }
                
                guard let bgCSS = bg.componentsCSS()?.css,
                    let primCSS = prim.componentsCSS()?.css,
                    let secCSS = sec.componentsCSS()?.css,
                    let detCSS = det.componentsCSS()?.css
                    else {
                        throw DemoAppError.colorDetectorFailed
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
                    updateBGColorLabels(string: bgCSS + " " + match)
                } else {
                    if shouldUpdateColorNames {
                        // Basic request cache to avoid launching the same request several times before the first one finishes
                        if cache[bgCSS] == nil {
                            cache[bgCSS] = 1
                            downloader.getName(for: bg) { name in
                                self.updateBGColorLabels(string: bgCSS + " " + name)
                                self.namedColors[bgCSS] = name
                            }
                        } else {
                            cache[bgCSS]! += 1
                        }
                    }
                }
                
                if let match = namedColors[primCSS] {
                    primaryColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[primCSS] == nil {
                            cache[primCSS] = 1
                            downloader.getName(for: prim) { name in
                                self.primaryColorNameLabel.stringValue = name
                                self.namedColors[primCSS] = name
                            }
                        } else {
                            cache[primCSS]! += 1
                        }
                    }
                }
                
                if let match = namedColors[secCSS] {
                    secondaryColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[secCSS] == nil {
                            cache[secCSS] = 1
                            downloader.getName(for: sec) { name in
                                self.secondaryColorNameLabel.stringValue = name
                                self.namedColors[secCSS] = name
                            }
                        } else {
                            cache[secCSS]! += 1
                        }
                    }
                }
                
                if let match = namedColors[detCSS] {
                    detailColorNameLabel.stringValue = match
                } else {
                    if shouldUpdateColorNames {
                        if cache[detCSS] == nil {
                            cache[detCSS] = 1
                            downloader.getName(for: det) { name in
                                self.detailColorNameLabel.stringValue = name
                                self.namedColors[detCSS] = name
                            }
                        } else {
                            cache[detCSS]! += 1
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

    private func updateBGColorLabels(string: String) {
        primaryColorView.backgroundColorLabel.stringValue = string
        secondaryColorView.backgroundColorLabel.stringValue = string
        detailColorView.backgroundColorLabel.stringValue = string
    }

    @IBAction func showOverlayClicked(_ sender: NSButton) {
        showOverlay()
    }

    private func showOverlay() {
        if showOverlayButton.state == NSOnState {
            imageView.primaryDemoColorView.color = colorCandidates!.primary!.withAlphaComponent(0.9)
            imageView.secondaryDemoColorView.color = colorCandidates!.secondary!.withAlphaComponent(0.9)
            imageView.detailDemoColorView.color = colorCandidates!.detail!.withAlphaComponent(0.9)
            imageView.backgroundDemoColorView.color = colorCandidates!.background!.withAlphaComponent(0.9)
        } else {
            imageView.primaryDemoColorView.color = nil
            imageView.secondaryDemoColorView.color = nil
            imageView.detailDemoColorView.color = nil
            imageView.backgroundDemoColorView.color = nil
        }
    }

    @IBAction func managePresets(_ sender: NSButton) {
        window.beginSheet(presetsPanel, completionHandler: nil)
    }

    @IBAction func exportColorsToJSON(_ sender: NSMenuItem) {
        if let cols = colorCandidates {
            ExportColors.saveJSONFile(colors: cols)
        }
    }

    @IBAction func exportColorsToPNG(_ sender: NSMenuItem) {
        guard let _ = colorCandidates else { return }  // shouldn't be nil, but let's be sure
        showOverlayButton.isHidden = true
        if let png = backgroundView.makePNGFromView() {
            ExportColors.savePNGFile(data: png)
        }
        showOverlayButton.isHidden = false
    }

    @IBAction func openImageFile(_ sender: NSMenuItem) {
        let dialog = NSOpenPanel()
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        dialog.title = "Choose an image"
        dialog.runModal()
        if let chosenfile = dialog.url,
            let img = NSImage(contentsOf: chosenfile) {
            analyseImageAndSetImageView(with: img)
        }
    }

    private func getNamedColorsFromFile(path: String) throws {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String]
            else {
                throw DemoAppError.couldNotLoadColorNamesFile
        }
        namedColors = json
    }

    func getJSONFilePath() -> String? {
        let d = FileManager.SearchPathDirectory.documentDirectory
        let m = FileManager.SearchPathDomainMask.allDomainsMask
        guard let dirs:[NSString] = NSSearchPathForDirectoriesInDomains(d, m, true), !dirs.isEmpty else {
            return nil
        }
        return dirs[0].appendingPathComponent("colors_dic.json")
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











