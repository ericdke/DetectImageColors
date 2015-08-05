//  DEMO APP

//  SWIFT 2

import Cocoa

class ColorsFromImage {

    let colorDetector = ColorDetector()
    var resizedImage: NSImage?
    var colorCandidates: ColorCandidates?

    init() {}

    init(image: NSImage) {
        colorCandidates = colorDetector.getColorCandidatesFromImage(image)
    }

    func getColorsFromImage(image: NSImage) -> ColorCandidates? {
        if let resized = image.resizeToSquare() {
            resizedImage = resized
            colorCandidates = colorDetector.getColorCandidatesFromImage(resized)
        }
        return colorCandidates
    }

    func getColors() -> ColorCandidates? {
        if let img = resizedImage {
            colorCandidates = colorDetector.getColorCandidatesFromImage(img)
        }
        return colorCandidates
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
