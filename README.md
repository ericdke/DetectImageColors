# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/cbb542eb-28f6-4481-8ddb-be9974cab033/9524ebaa3b3e4889/res/aa8f243b-dc4f-4121-8606-e795730f72fd/skitch.png)

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

Download or clone the project, open in Xcode, build.

You can drop an image on the image view and tweak the sliders.

## Playground

A Playground is also included for demo purposes.

![Playground](https://www.evernote.com/shard/s89/sh/9188b56f-d2f5-44d3-a14f-55bd7c97e7cf/6c92794b3b4a606b/res/dfd99f98-c497-4eb1-8d84-d366484d0986/skitch.png)


## Todo

- Make a framework

- Make it iOS compatible

- Improve detector accuracy

- Improve post-detection adjustments

- Refactor pixel color detection

- Improve resize image speed