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

    func getColors(_ completion: (candidates: ColorCandidates?) -> Void) {
        DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes.qosDefault).async {
            let colors = self.getColors()
            DispatchQueue.main.async {
                completion(candidates: colors)
            }
        }
    }

}
