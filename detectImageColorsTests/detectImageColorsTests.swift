//
//  detectImageColorsTests.swift
//  detectImageColorsTests
//
//  Created by ERIC DEJONCKHEERE on 04/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa
import XCTest

class detectImageColorsTests: XCTestCase {

    let detector = ColorDetector()
    let reed = NSImage(named: "reed")!
    let elton = NSImage(named: "elton")!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDontResizeImage() {
        let resized = detector.resize(elton)
        XCTAssert(resized!.size.width == elton.size.width, "Did not resize if < 600")
    }

    func testWithMinimumSaturationMore() {
        let original = NSColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
        let originalSaturation = original.saturationComponent
        let withMinimumSaturation = original.withMinimumSaturation(CDSettings.ThresholdMinimumSaturation)
        let resultSaturation = withMinimumSaturation.saturationComponent
        XCTAssert(resultSaturation > originalSaturation, "Color is more saturated")
    }

    func testWithMinimumSaturationSame() {
        let original = NSColor.greenColor()
        let originalSaturation = original.saturationComponent
        let withMinimumSaturation = original.withMinimumSaturation(CDSettings.ThresholdMinimumSaturation)
        let resultSaturation = withMinimumSaturation.saturationComponent
        XCTAssert(resultSaturation == originalSaturation, "Color is saturated enough")
    }

    func testLighterColor() {
        let original = NSColor.blackColor()
        let calibratedOriginal = original.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)!
        let originalRed = calibratedOriginal.redComponent
        let lighter = calibratedOriginal.lighterColor()
        let lighterRed = lighter.redComponent
        XCTAssert(lighterRed > originalRed, "Color is lightened")
    }

    func testDarkerColor() {
        let original = NSColor.whiteColor()
        let calibratedOriginal = original.colorUsingColorSpaceName(NSCalibratedRGBColorSpace)!
        let originalRed = calibratedOriginal.redComponent
        let darker = calibratedOriginal.darkerColor()
        let darkerRed = darker.redComponent
        XCTAssert(originalRed > darkerRed, "Color is darkened")
    }

    func testIsMostlyDarkColor() {
        let original = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        var isMostlyDarkColor = original.isMostlyDarkColor()
        XCTAssert(isMostlyDarkColor, "Dark color is dark")
        let light = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        isMostlyDarkColor = light.isMostlyDarkColor()
        XCTAssert(!isMostlyDarkColor, "Light color is not dark")
    }

    func testIsNearOf() {
        let colA = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let colB = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let isNearOf = colA.isNearOf(colB)
        XCTAssert(isNearOf, "Dark color is near another dark color")
        // TODO: problems with some colors
    }

    func testIsMostlyBlackOrWhite() {
        let middle = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        var isMostlyBlackOrWhite = middle.isMostlyBlackOrWhite()
        XCTAssert(!isMostlyBlackOrWhite, "Middle color is not mostly black or white")
        let white = NSColor.whiteColor()
        isMostlyBlackOrWhite = white.isMostlyBlackOrWhite()
        XCTAssert(isMostlyBlackOrWhite, "White color is mostly black or white")
    }

    func testDoesNotContrastWith() {
        let colA = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let colB = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        var doesNotContrastWith = colA.doesNotContrastWith(colB)
        XCTAssert(doesNotContrastWith, "Dark color does not contrast with another dark color")
        let colC = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        doesNotContrastWith = colA.doesNotContrastWith(colC)
        XCTAssert(!doesNotContrastWith, "Middle color does contrast with a dark color")
    }

    func testChangeSomeSetting() {
        let minP = CDSettings.ThresholdMinimumPercentage
        CDSettings.ThresholdMinimumPercentage = 0.75
        XCTAssert(minP != CDSettings.ThresholdMinimumPercentage, "Setting changed")
        XCTAssert(CDSettings.ThresholdMinimumPercentage == 0.75, "Setting changed")
    }

    func testCreateColorCandidates() {
        let resized = detector.resize(reed)!
        let candidates = detector.getColorCandidatesFromImage(resized)
        XCTAssert(candidates != nil, "Candidates not nil")
        XCTAssert(candidates!.primary != nil, "Candidates primary color not nil")
        XCTAssert(candidates!.secondary != nil, "Candidates secondary color not nil")
        XCTAssert(candidates!.detail != nil, "Candidates detail color not nil")
        XCTAssert(candidates!.background != nil, "Candidates background color not nil")
        XCTAssert(candidates!.backgroundIsBlackOrWhite != nil, "Candidates backgroundIsBlackOrWhite color not nil")
        XCTAssert(candidates!.backgroundIsDark != nil, "Candidates backgroundIsDark color not nil")
    }

    func testPerformanceCountedSet() {
        let resized = detector.resize(elton)!
        let imageRep = resized.representations.last as! NSBitmapImageRep
        let pixelsWide = imageRep.pixelsWide
        CDSettings.DetectorResolution = 1
        self.measureBlock() {
            let _ = self.detector.sampleImage(width: pixelsWide, height: pixelsWide, imageRep: imageRep)
        }
    }

    func testPerformanceBytes() {
        let resized = detector.resize(elton)!
        let imageRep = resized.representations.last as! NSBitmapImageRep
        let pixelsWide = imageRep.pixelsWide
        self.measureBlock() {
            let _ = self.detector.sampleImageWithBytes(width: pixelsWide, height: pixelsWide, imageRep: imageRep)
        }
    }


}
