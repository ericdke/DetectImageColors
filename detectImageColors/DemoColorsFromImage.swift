//
//  ColorsFromImage.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 07/06/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

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
        if let resized = colorDetector.resize(image) {
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
