//  DEMO APP

//  SWIFT 2

import Cocoa

class DemoImageView: NSImageView {

    let primaryDemoColorView = DemoColorView()
    let secondaryDemoColorView = DemoColorView()
    let detailDemoColorView = DemoColorView()
    let backgroundDemoColorView = DemoColorView()
    
    let downloader = Downloader()

    override func draw(_ dirtyRect: NSRect) {
        addColorView()
        super.draw(dirtyRect)
    }

    func addColorView() {
        primaryDemoColorView.frame = NSMakeRect(50, (self.bounds.height / 2) - 25, 50, 50)
        primaryDemoColorView.isMovable = true
        secondaryDemoColorView.frame = NSMakeRect(125, (self.bounds.height / 2) - 25, 50, 50)
        secondaryDemoColorView.isMovable = true
        detailDemoColorView.frame = NSMakeRect(200, (self.bounds.height / 2) - 25, 50, 50)
        detailDemoColorView.isMovable = true
        backgroundDemoColorView.frame = NSMakeRect(275, (self.bounds.height / 2) - 25, 50, 50)
        backgroundDemoColorView.isMovable = true
        self.addSubview(primaryDemoColorView)
        self.addSubview(secondaryDemoColorView)
        self.addSubview(detailDemoColorView)
        self.addSubview(backgroundDemoColorView)
    }

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "JPG", "JPEG", "BMP", "PNG", "GIF"]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        register(forDraggedTypes: [NSFilenamesPboardType,NSURLPboardType,NSPasteboardTypeTIFF])
    }

    override func viewDidMoveToWindow() {
        toolTip = "Drop an image here."
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let p = sender.draggingPasteboard()
        if let p1 = p.propertyList(forType: "NSFilenamesPboardType") as? [AnyObject],
            let pathStr = p1[0] as? String, checkExtension(pathStr: pathStr) {
                imageDropped(paste: (.path, pathStr))
                return true
        } else if let p2 = p.propertyList(forType: "WebURLsWithTitlesPboardType") as? [AnyObject],
            let temp = p2.first as? [AnyObject],
            let pathStr = temp.first as? String {
                imageDropped(paste: (.url, pathStr))
                return true
        }
        return false
    }

    private func imageDropped(paste: (type: DragType, value: String)) {
        if paste.type == .path {
            if let img = NSImage(contentsOfFile: paste.value) {
                updateImage(image: img)
            }
        } else {
            let rules = CharacterSet.urlQueryAllowed
            if let escapedPath = paste.value.addingPercentEncoding(withAllowedCharacters: rules),
                let url = URL(string: escapedPath) {
                downloadImage(url: url)
            }
        }
    }

    private func downloadImage(url: URL) {
        downloader.download(url: url) { (data) -> Void in
            if let img = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.updateImage(image: img)
                }
            }
        }
    }

    private func updateImage(image: NSImage) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateImageByDropOK"),
                                          object: nil,
                                          userInfo: ["image": image])
    }

    private func checkExtension(pathStr: String) -> Bool {
        let url = URL(fileURLWithPath: pathStr)
        if let suffix = url.pathExtension {
            for ext in fileTypes {
                if ext == suffix.lowercased() {
                    return true
                }
            }
        }
        return false
    }

}
