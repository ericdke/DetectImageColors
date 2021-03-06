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

    let reed = NSImage(named: NSImage.Name(rawValue: "reed"))!
    let elton = NSImage(named: NSImage.Name(rawValue: "elton"))!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWithMinimumSaturationMore() {
        let original = NSColor(red: 1, green: 0.9, blue: 0.9, alpha: 1)
        let originalSaturation = original.saturationComponent
        let wms = original.applyingSaturation(minimum: CDSettings.thresholdMinimumSaturation)
        let resultSaturation = wms.saturationComponent
        XCTAssert(resultSaturation > originalSaturation, "Color is more saturated")
    }

    func testWithMinimumSaturationSame() {
        let original = NSColor.green
        let originalSaturation = original.saturationComponent
        let wms = original.applyingSaturation(minimum: CDSettings.thresholdMinimumSaturation)
        let resultSaturation = wms.saturationComponent
        XCTAssert(resultSaturation == originalSaturation, "Color is saturated enough")
    }

    func testLighterColor() {
        let original = NSColor.black
        let calibratedOriginal = original.usingColorSpaceName(NSColorSpaceName.calibratedRGB)!
        let originalRed = calibratedOriginal.redComponent
        let lighter = calibratedOriginal.lighter()
        let lighterRed = lighter.redComponent
        XCTAssert(lighterRed > originalRed, "Color is lightened")
    }

    func testDarkerColor() {
        let original = NSColor.white
        let calibratedOriginal = original.usingColorSpaceName(NSColorSpaceName.calibratedRGB)!
        let originalRed = calibratedOriginal.redComponent
        let darker = calibratedOriginal.darker()
        let darkerRed = darker.redComponent
        XCTAssert(originalRed > darkerRed, "Color is darkened")
    }

    func testIsMostlyDarkColor() {
        let original = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        var isMostlyDarkColor = original.isMostlyDarkColor
        XCTAssert(isMostlyDarkColor, "Dark color is dark")
        let light = NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        isMostlyDarkColor = light.isMostlyDarkColor
        XCTAssert(!isMostlyDarkColor, "Light color is not dark")
    }

    func testIsNearOf() {
        let colA = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let colB = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let isNearOf = colA.isNear(of: colB)
        XCTAssert(isNearOf, "Dark color is near another dark color")
        // TODO: problems with some colors
    }

    func testIsMostlyBlackOrWhite() {
        let middle = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        var isMostlyBlackOrWhite = middle.isMostlyBlackOrWhite
        XCTAssert(!isMostlyBlackOrWhite, "Middle color is not mostly black or white")
        let white = NSColor.white
        isMostlyBlackOrWhite = white.isMostlyBlackOrWhite
        XCTAssert(isMostlyBlackOrWhite, "White color is mostly black or white")
    }

    func testDoesNotContrastWith() {
        let colA = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        let colB = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        var doesNotContrastWith = !colA.contrastsWith(colB)
        XCTAssert(doesNotContrastWith, "Dark color does not contrast with another dark color")
        let colC = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        doesNotContrastWith = !colA.contrastsWith(colC)
        XCTAssert(!doesNotContrastWith, "Middle color does contrast with a dark color")
    }

    func testChangeSomeSetting() {
        let minP = CDSettings.thresholdMinimumPercentage
        CDSettings.thresholdMinimumPercentage = 0.75
        XCTAssert(minP != CDSettings.thresholdMinimumPercentage, "Setting changed")
        XCTAssert(CDSettings.thresholdMinimumPercentage == 0.75, "Setting changed")
    }

    func testCreateColorCandidates() {
        let candidates = reed.getColorCandidates()
        XCTAssert(candidates != nil, "Candidates not nil")
        XCTAssert(candidates!.primary != nil, "Candidates primary color not nil")
        XCTAssert(candidates!.secondary != nil, "Candidates secondary color not nil")
        XCTAssert(candidates!.detail != nil, "Candidates detail color not nil")
        XCTAssert(candidates!.background != nil, "Candidates background color not nil")
        XCTAssert(candidates!.backgroundIsBlackOrWhite != nil, "Candidates backgroundIsBlackOrWhite color not nil")
        XCTAssert(candidates!.backgroundIsDark != nil, "Candidates backgroundIsDark color not nil")
    }

}
