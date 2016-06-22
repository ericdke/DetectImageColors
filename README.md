![](https://img.shields.io/badge/Swift-3-orange.svg?style=flat)

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

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/691456c3-1d2b-4b3c-8faf-2105af6bb380/e43f803817a7a7a2/res/2d53de18-7bc0-444a-adea-40bc2213e48d/skitch.png)

Download or clone the project, open in Xcode, build (Swift 3 only: Xcode 8+).

You can drop a new image on the image view and tweak the sliders to find values you like for the thresholds and ratios.

## Playground

A Playground is also included for demo purposes.

![Playground](https://www.evernote.com/shard/s89/sh/f223b9ae-e80e-42e1-a5ea-84440b04d3d1/9c0807d8f4b67d31/res/c0740876-dc0d-4000-b10f-b277e71f4d40/skitch.png)

## Todo

Suggestions and contributions are welcomed! 

- Improve detector accuracy (see comments in `CDColorDetector.swift`)

- Improve detector speed

- Improve resize image method

- Make a better demo app

- Make a framework

- Make it iOS compatible

## History

This started has a translation from Objective-C to Swift of [Color Art](https://github.com/panicinc/ColorArt) by Panic Software, from their 2011 blog article.

Then after lots of changes and optimizations (and a few regressions) I added new features like color names and customizable parameters.

I've also made a simple demo app to test the color detection.

## Disclaimer

This is only a programming exercise, to explore possibilities - this is not for production.

If you're looking for performance in color detection, see my Swift 2 fork of Indragie Karunaratne's [DominantColor](https://github.com/ericdke/DominantColor) instead.

## Licence

MIT but you have to refer to Panic's repository somewhere visible.