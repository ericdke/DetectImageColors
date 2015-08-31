//  DEMO APP

//  SWIFT 2

import Cocoa

class ColorsFromImage {

    var image: NSImage?
    var colorCandidates: ColorCandidates?

    init() {}

    init(image: NSImage) {
        colorCandidates = image.getColorCandidates()
    }

    func getColorsFromImage(image: NSImage) -> ColorCandidates? {
        return image.getColorCandidates()
    }

    func getColors() -> ColorCandidates? {
        if let image = image {
            return image.getColorCandidates()
        }
        return nil
    }

    func getColors(completion: (candidates: ColorCandidates?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let colors = self.getColors()
            dispatch_async(dispatch_get_main_queue()) {
                completion(candidates: colors)
            }
        }
    }

}
