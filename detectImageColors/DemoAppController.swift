//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    var colorsFromImage = ColorsFromImage()
    var namedColors = [String:String]()
    let downloader = Downloader()
    var appDelegate: AppDelegate?

    var colorCandidates: ColorCandidates? {
        didSet {
            spinner.stopAnimation(nil)
            refreshWindowElements()
        }
    }

    private func updateColorCandidates() {
        spinner.startAnimation(nil)
        colorCandidates = colorsFromImage.getColors()
    }

    func updateColorCandidates(notification: NSNotification) {
        updateColorCandidates()
    }

    override func awakeFromNib() {
        if let dg = NSApplication.sharedApplication().delegate as? AppDelegate {
            self.appDelegate = dg
            if let path = dg.getJSONFilePath() {
                if NSFileManager().fileExistsAtPath(path) {
                    getNamedColorsFromFile(path)
                } else {
                    if let path = NSBundle.mainBundle().pathForResource("colors_dic", ofType: "json") {
                        getNamedColorsFromFile(path)
                    }
                }
            }
        }
        analyseImageAndSetImageView(NSImage(named: "elton")!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateImage:", name: "updateImageByDropOK", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateColorCandidates:", name: "updateColorCandidatesOK", object: nil)
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

            primaryColorView.color = cols.primary
            primaryColorView.backgroundColorLabel.textColor = cols.background
            primaryColorLabel.textColor = cols.primary
            primaryColorLabel.stringValue = primCSS
            secondaryColorView.color = cols.secondary
            secondaryColorView.backgroundColorLabel.textColor = cols.background
            secondaryColorLabel.textColor = cols.secondary
            secondaryColorLabel.stringValue = secCSS
            detailColorView.color = cols.detail
            detailColorView.backgroundColorLabel.textColor = cols.background
            detailColorLabel.textColor = cols.detail
            detailColorLabel.stringValue = detCSS
            backgroundView.colorCandidates = cols

            primaryColorNameLabel.textColor = cols.primary
            secondaryColorNameLabel.textColor = cols.secondary
            detailColorNameLabel.textColor = cols.detail

            showOverlay()

            if let match = namedColors[bgCSS] {
                updateBGColorLabels(bgCSS + " " + match)
            } else {
                getColorNameFromAPI(bgCSS, completionHandler: { (name) -> Void in
                    self.updateBGColorLabels(bgCSS + " " + name)
                    self.namedColors[bgCSS] = name
                })
            }
            if let match = namedColors[primCSS] {
                primaryColorNameLabel.stringValue = match
            } else {
                getColorNameFromAPI(primCSS, completionHandler: { (name) -> Void in
                    self.primaryColorNameLabel.stringValue = name
                    self.namedColors[primCSS] = name
                })
            }
            if let match = namedColors[secCSS] {
                secondaryColorNameLabel.stringValue = match
            } else {
                getColorNameFromAPI(secCSS, completionHandler: { (name) -> Void in
                    self.secondaryColorNameLabel.stringValue = name
                    self.namedColors[secCSS] = name
                })
            }
            if let match = namedColors[detCSS] {
                detailColorNameLabel.stringValue = match
            } else {
                getColorNameFromAPI(detCSS, completionHandler: { (name) -> Void in
                    self.detailColorNameLabel.stringValue = name
                    self.namedColors[detCSS] = name
                })
            }

            //TODO: it makes a copy in the AppDelegate everytime. Not good. Fix it.
            if let dg = self.appDelegate {
                dg.namedColors = namedColors
            }

        }
    }

    private func updateBGColorLabels(str: String) {
        primaryColorView.backgroundColorLabel.stringValue = str
        secondaryColorView.backgroundColorLabel.stringValue = str
        detailColorView.backgroundColorLabel.stringValue = str
    }

    private func getColorNameFromAPI(css: String, completionHandler: (name: String) -> Void) {
        let c = css.componentsSeparatedByString("#")[1]
        let url = downloader.colorsAPIbaseURL + c
        downloader.download(url, completion: { (data) -> Void in
            if let json = self.downloader.JSONDataToDictionary(data) {
                if let dic = json["name"] as? [String:AnyObject] {
                    if let name = dic["value"] as? String {
                        completionHandler(name: name)
                    }
                }
            }
        })
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
        if let cols = colorCandidates {
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
        let data = NSData(contentsOfFile: path)
        let json = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! [String:String]
        namedColors = json
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











