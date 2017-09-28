//  DEMO APP

import Cocoa

class AppController: NSObject, ImageDropDelegate, ControlsDelegate {
    
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
    @IBOutlet weak var presetsPanel: DemoPresetsPanel!
    @IBOutlet weak var controlsView: DemoControlsView!

    var colorsFromImage = ColorsFromImage()
    var namedColors = [String:String]()
    let downloader = Downloader()
    let filesManager = FilesManager()
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
            guard let elton = NSImage(named: NSImage.Name(rawValue: "elton")) else {
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
        // custom file vs default file
        guard let jpath = filesManager.getJSONFilePath() else {
            throw DemoAppError.invalidFilePath
        }
        if filesManager.fileExists(at: jpath) {
            namedColors = try filesManager.namedColorsFromFile(path: jpath)
        } else {
            guard let bpath = filesManager.colorsPath else {
                throw DemoAppError.invalidFilePath
            }
            namedColors = try filesManager.namedColorsFromFile(path: bpath)
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
                colorName(for: primaryColorNameLabel, css: primCSS, col: prim)
                colorName(for: secondaryColorNameLabel, css: secCSS, col: sec)
                colorName(for: detailColorNameLabel, css: detCSS, col: det)
                
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
            updateBGColorLabels(string: "BG: \(css) \(match)")
        } else {
            if shouldUpdateColorNames {
                if cache[css] == nil {
                    cache[css] = 1
                    downloader.getName(for: bg) { name in
                        DispatchQueue.main.async {
                            self.namedColors[css] = name
                            self.updateBGColorLabels(string: "BG: \(css) \(name)")
                        }
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
    
    private func colorName(for label: NSTextField, css: String, col: NSColor) {
        if let match = namedColors[css] {
            label.stringValue = match
        } else {
            if shouldUpdateColorNames {
                if cache[css] == nil {
                    cache[css] = 1
                    downloader.getName(for: col) { name in
                        self.namedColors[css] = name
                        DispatchQueue.main.async {
                            label.stringValue = name
                        }
                    }
                } else {
                    cache[css]! += 1
                }
            }
        }
    }

    @IBAction func showOverlayClicked(_ sender: NSButton) {
        showOverlay()
    }
    
    private func showOverlay() {
        if showOverlayButton.state == .on {
            imageView.showOverlay(candidates: colorCandidates)
        } else {
            imageView.showOverlay(candidates: nil)
        }
    }

    @IBAction func managePresets(_ sender: NSButton) {
        window.beginSheet(presetsPanel, completionHandler: nil)
    }

    @IBAction func exportColorsToJSON(_ sender: NSMenuItem) {
        if let cols = colorCandidates {
            Modals.save(json: cols.JSONData)
        }
    }

    @IBAction func exportColorsToPNG(_ sender: NSMenuItem) {
        guard let _ = colorCandidates else { return }  // shouldn't be nil, but let's be sure
        showOverlayButton.isHidden = true
        if let png = backgroundView.makePNGFromView() {
            Modals.save(png: png)
        }
        showOverlayButton.isHidden = false
    }

    @IBAction func openImageFile(_ sender: NSMenuItem) {
        if let url = Modals.selectImageURL(),
            let img = NSImage(contentsOf: url) {
            analyseImageAndSetImageView(with: img)
        }
    }

    


}











