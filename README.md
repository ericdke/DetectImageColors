# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

## Code Usage

1. Grab the files which name begins with "CD" and copy them to your Xcode Swift project.

2. Optional: tweak `CDSettings` variables

3. Create color candidates from image:

```  
let image = NSImage(named: "elton")  
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized)
```  

## Demo Application

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/7f539a6e-05d9-4d86-8c0e-14a6eeff11e8/04c165ed2039a358/res/eef73a0d-0a10-4de5-a79d-e00344842b34/skitch.png)

Download or clone the project, open in Xcode, build.

You can drop a new image on the image view and tweak the sliders to find values you like for the thresholds and ratios.

## Playground

A Playground is also included for demo purposes.

![Playground](https://www.evernote.com/shard/s89/sh/f223b9ae-e80e-42e1-a5ea-84440b04d3d1/9c0807d8f4b67d31/res/c0740876-dc0d-4000-b10f-b277e71f4d40/skitch.png)

## Swift version

There's two branches in this project:

- `master` is the master development branch

- `swift2` is the new version

For now, any *feature* change in one of the two branches is translated to the other.

Later this year when Swift 2 and Xcode 7 won't be in beta anymore, the `master` branch will be renamed to `legacy` and will be abandoned, and `swift2` will become the new `master` branch.

## Todo

Suggestions and contributions are welcomed! 

- Improve detector accuracy (see comments in `CDColorDetector.swift`)

- Improve resize image method

- Make a better demo app

- Make a framework

- Make it iOS compatible