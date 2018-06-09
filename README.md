![](https://img.shields.io/badge/Swift-4.2-green.svg?style=flat) ![](https://img.shields.io/badge/Xcode-9-green.svg?style=flat)

# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

## Code Usage

1. Grab the files which name begins with "CD" and copy them to your Xcode Swift project.

2. Optional: tweak `CDSettings` variables

3. Create color candidates from image:

```   
let colorCandidates = image.getColorCandidates()
```  

## Demo Application

![Demo app](https://monosnap.com/file/B9JEWrL0G6xxvmBLWAFmniGAdJG0s4.png)

Download or clone the project, open in Xcode, build (Swift 4, Xcode 9).

You can drop a new image on the image view and tweak the sliders to find values you like for the thresholds and ratios.

## Playground

A Playground is also included for demo purposes.

![Playground](https://monosnap.com/file/LU2oR9KpLQ7cUEYsdxOiw0jhDy8Qif.png)

## Public methods and properties

`NSImage` extension:

    func getColorCandidates() -> ColorCandidates?
    var isImageSquared: Bool

`NSColor` extension:

    func isNear(of: NSColor) -> Bool
    func lighter(threshold: CGFloat = default, ratio: CGFloat = default) -> NSColor
    func darker(threshold: CGFloat = default, ratio: CGFloat = default) -> NSColor
    func applyingSaturation(minimum: CGFloat) -> NSColor
    func contrastsWith(_: NSColor) -> Bool
    var isMostlyBlackOrWhite: Bool
    var isMostlyDarkColor: Bool
    func componentsCSS() -> (alpha: String, red: String, green: String, blue: String, css: String, clean: String)?
    func componentsNSC() -> (alpha: CGFloat, red: CGFloat, green: CGFloat, blue: CGFloat)?
    func componentsRGB() -> (alpha: Int, red: Int, green: Int, blue: Int)?
    func componentsHUE() -> (alpha: CGFloat, hue: CGFloat, saturation: CGFloat, brightness: CGFloat)?

`ColorCandidates` struct:

    var primary: NSColor?
    var secondary: NSColor?
    var detail: NSColor?
    var background: NSColor?
    var backgroundIsDark: Bool?
    var backgroundIsBlackOrWhite: Bool?
    var JSONData: Data

`CDSettings` class:

    var thresholdMinimumPercentage: Double
    var thresholdMinimumSaturation: CGFloat
    var thresholdNoiseTolerance: Int
    var thresholdFloorBrightness: CGFloat
    var thresholdCeilingBrightness: CGFloat
    var thresholdDistinctColor: CGFloat
    var thresholdGrey: CGFloat
    var minThresholdWhite: CGFloat
    var maxThresholdBlack: CGFloat
    var lighterRatio: CGFloat
    var darkerRatio: CGFloat
    var contrastRatio: CGFloat
    var luminanceAddedWeight: CGFloat
    var YUVRedRatio: CGFloat
    var YUVGreenRatio: CGFloat
    var YUVBlueRatio: CGFloat
    var detectorDistanceFromLeftEdge: Int
    var detectorResolution: Int
    var ensureContrastedColorCandidates: Bool

## Todo

Suggestions and contributions are welcomed! 

- Improve detector accuracy

- Improve detector speed

- Improve resize image method

- Make it iOS compatible

- Make a better demo app

## History

This started has a translation from Objective-C to Swift of [Color Art](https://github.com/panicinc/ColorArt) by Panic Software, from their 2011 blog article.

Then after lots of changes and optimizations (and a few regressions) I added new features like color names and customizable parameters.

I've also made a simple demo app to test the color detection.

## Disclaimer

This is only a programming exercise, to explore possibilities - this is **not for production**.

If you're looking for performance in color detection, see my Swift 2 fork of Indragie Karunaratne's [DominantColor](https://github.com/ericdke/DominantColor) instead.

## Licence

MIT but you have to refer to this page and to Panic's repository somewhere visible.
