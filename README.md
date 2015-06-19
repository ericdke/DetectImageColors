# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

## Usage

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

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/cbb542eb-28f6-4481-8ddb-be9974cab033/9524ebaa3b3e4889/res/aa8f243b-dc4f-4121-8606-e795730f72fd/skitch.png)

Download or clone the project, open in Xcode, build.

You can drop a new image on the image view and tweak the sliders to find values you like for the thresholds and ratios.

## Playground

A Playground is also included for demo purposes.

![Playground](https://www.evernote.com/shard/s89/sh/9188b56f-d2f5-44d3-a14f-55bd7c97e7cf/6c92794b3b4a606b/res/dfd99f98-c497-4eb1-8d84-d366484d0986/skitch.png)

## Todo

Suggestions and contributions are welcomed!

- Make a framework

- Make it iOS compatible

- Improve detector accuracy (see `CDColorDetector.swift`)

- Improve resize image speed

- Make a better demo app