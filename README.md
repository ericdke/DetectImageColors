# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

## Code Usage

1. Grab the files which name begins with "CD" and copy them to your Xcode Swift project.

2. Optional: tweak CDSettings class variables

3. Create color candidates from image

```  
let image = NSImage(named: "elton")  
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized)
```  

## Demo Application

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/2502e27a-74d7-4fb7-9441-a0c35d8599ab/74dd7317030045ca/res/00eee34f-dfda-4641-ad28-6eb007652bdc/skitch.png)

Download or clone the project, open in Xcode, build.

You can drop a new image on the image view and tweak the sliders to find values you like for the thresholds and ratios.

## Playground

A Playground is also included for demo purposes.

![Playground](https://www.evernote.com/shard/s89/sh/f223b9ae-e80e-42e1-a5ea-84440b04d3d1/9c0807d8f4b67d31/res/c0740876-dc0d-4000-b10f-b277e71f4d40/skitch.png)

## Todo

Suggestions and contributions are welcomed!

- Make a framework

- Make it iOS compatible

- Improve detector accuracy (see `CDColorDetector.swift`)

- Improve resize image speed

- Make a better demo app