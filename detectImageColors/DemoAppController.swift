//  DEMO APP

import Cocoa

class AppController: NSObject, ImageDropDelegate, ControlsDelegate {

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
    
    func updateColorCandidates(mouseUp: Bool) {
        shouldUpdateColorNames = mouseUp
        updateColorCandidates()
    }

    override func awakeFromNib() {
        imageView.dropDelegate = self
        controlsView.controlsDelegate = self
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
    
    // delegate
    func updateImage(image: NSImage) {
        analyseImageAndSetImageView(with: image)
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
                
                refreshLabels(prim, sec, det, bg)
                
                primaryColorLabel.stringValue = primCSS
                secondaryColorLabel.stringValue = secCSS
                detailColorLabel.stringValue = detCSS
                
                backgroundView.colorCandidates = cols
                
                showOverlay()
                
                colorNameForLabelBG(css: bgCSS, bg: bg)
                colorName(for: primaryColorLabel, css: primCSS, col: prim)
                colorName(for: secondaryColorLabel, css: secCSS, col: sec)
                colorName(for: detailColorLabel, css: detCSS, col: det)
                
                spinner.stopAnimation(nil)
                window.display()
                
            } catch let demoAppError as DemoAppError {
                print(demoAppError.rawValue)
            } catch {
                print(error)
            }
        }
    }
    
    private func refreshLabels(_ prim: NSColor, _ sec: NSColor, _ det: NSColor, _ bg: NSColor) {
        primaryColorView.color = prim
        primaryColorLabel.textColor = prim
        primaryColorNameLabel.textColor = prim
        secondaryColorView.color = sec
        secondaryColorLabel.textColor = sec
        secondaryColorNameLabel.textColor = sec
        detailColorView.color = det
        detailColorLabel.textColor = det
        detailColorNameLabel.textColor = det
        primaryColorView.backgroundColorLabel.textColor = bg
        secondaryColorView.backgroundColorLabel.textColor = bg
        detailColorView.backgroundColorLabel.textColor = bg
    }
    
    private func colorNameForLabelBG(css: String, bg: NSColor) {
        if let match = namedColors[css] {
            updateBGColorLabels(string: css + " " + match)
        } else {
            if shouldUpdateColorNames {
                if cache[css] == nil {
                    cache[css] = 1
                    downloader.getName(for: bg) { name in
                        self.namedColors[css] = name
                        self.updateBGColorLabels(string: css + " " + name)
                    }
                } else {
                    cache[css]! += 1
                }
            }
        }
    }
    
    private func colorName(for label: NSTextField, css: String, col: NSColor) {
        if let match = namedColors[css] {
            label.stringValue = match
        } else {
            if shouldUpdateColorNames {
                if cache[css] == nil {
                    cache[css] = 1
                    downloader.getName(for: col) { name in
                        self.namedColors[css] = name
                        label.stringValue = name
                    }
                } else {
                    cache[css]! += 1
                }
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

    @IBOutlet weak var controlsView: DemoControlsView!
}











