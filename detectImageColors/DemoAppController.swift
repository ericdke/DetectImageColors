//
//  AppController.swift
//  detectImageColors
//  Demo app

import Cocoa

class AppController: NSObject {

    var colorsFromImage = ColorsFromImage()

    var colorCandidates: ColorCandidates? {
        didSet {
            spinner.stopAnimation(nil)
            refreshWindowElements()
        }
    }

    func updateColorCandidates() {
        spinner.startAnimation(nil)
        colorCandidates = colorsFromImage.getColors()
    }

    func updateColorCandidates(notification: NSNotification) {
        updateColorCandidates()
    }

    override func awakeFromNib() {
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
            primaryColorView.color = cols.primary
            primaryColorView.backgroundColorLabel.textColor = cols.background
            primaryColorView.backgroundColorLabel.stringValue = bgCSS
            primaryColorLabel.textColor = cols.primary
            primaryColorLabel.stringValue = cols.primary!.componentsCSS()!.css
            secondaryColorView.color = cols.secondary
            secondaryColorView.backgroundColorLabel.textColor = cols.background
            secondaryColorView.backgroundColorLabel.stringValue = bgCSS
            secondaryColorLabel.textColor = cols.secondary
            secondaryColorLabel.stringValue = cols.secondary!.componentsCSS()!.css
            detailColorView.color = cols.detail
            detailColorView.backgroundColorLabel.textColor = cols.background
            detailColorView.backgroundColorLabel.stringValue = bgCSS
            detailColorLabel.textColor = cols.detail
            detailColorLabel.stringValue = cols.detail!.componentsCSS()!.css
            backgroundView.colorCandidates = cols
            showOverlay()
        }
    }

    @IBAction func showOverlayClicked(sender: NSButton) {
        showOverlay()
    }

    func showOverlay() {
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
        let myFiledialog: NSOpenPanel = NSOpenPanel()
        myFiledialog.allowsMultipleSelection = false
        myFiledialog.canChooseDirectories = false
        myFiledialog.allowedFileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]
        myFiledialog.title = "Choose an image"
        myFiledialog.runModal()
        if let chosenfile = myFiledialog.URL, path = chosenfile.path, img = NSImage(contentsOfFile: path) {
            analyseImageAndSetImageView(img)
        }
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

}











