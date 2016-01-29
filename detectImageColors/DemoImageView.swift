//  DEMO APP

//  SWIFT 2

import Cocoa

class DemoImageView: NSImageView {

    let primaryDemoColorView = DemoColorView()
    let secondaryDemoColorView = DemoColorView()
    let detailDemoColorView = DemoColorView()
    let backgroundDemoColorView = DemoColorView()
    
    let downloader = Downloader()

    override func drawRect(dirtyRect: NSRect) {
        addColorView()
        super.drawRect(dirtyRect)
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
        registerForDraggedTypes([NSFilenamesPboardType,NSURLPboardType,NSPasteboardTypeTIFF])
    }

    override func viewDidMoveToWindow() {
        toolTip = "Drop an image here."
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return .Copy
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        if let p1 = sender.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? [AnyObject],
            pathStr = p1[0] as? String where checkExtension(pathStr) {
                imageDropped((.Path, pathStr))
                return true
        } else if let p2 = sender.draggingPasteboard().propertyListForType("WebURLsWithTitlesPboardType") as? [AnyObject],
            temp = p2.first as? [AnyObject],
            pathStr = temp.first as? String {
                imageDropped((.URL, pathStr))
                return true
        }
        return false
    }

    private func imageDropped(paste: (type: DragType, value: String)) {
        if paste.type == .Path {
            if let img = NSImage(contentsOfFile: paste.value) {
                updateImage(img)
            }
        } else {
            let rules = NSCharacterSet.URLQueryAllowedCharacterSet()
            if let escapedPath = paste.value.stringByAddingPercentEncodingWithAllowedCharacters(rules), let url = NSURL(string: escapedPath) {
                downloadImage(url)
            }
        }
    }

    private func downloadImage(url: NSURL) {
        downloader.download(url.absoluteString) { (data) -> Void in
            if let img = NSImage(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateImage(img)
                }
            }
        }
    }

    private func updateImage(image: NSImage) {
        NSNotificationCenter.defaultCenter().postNotificationName("updateImageByDropOK", object: nil, userInfo: ["image": image])
    }

    private func checkExtension(pathStr: String) -> Bool {
        let url = NSURL(fileURLWithPath: pathStr)
        if let suffix = url.pathExtension {
            for ext in fileTypes {
                if ext == suffix.lowercaseString {
                    return true
                }
            }
        }
        return false
    }

}
