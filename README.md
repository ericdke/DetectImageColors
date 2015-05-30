# Detect Image Colors

Extracts 4 main colors from an image: primary, secondary, detail and background.

![DetectImageColors demo app](https://www.evernote.com/shard/s89/sh/cbb542eb-28f6-4481-8ddb-be9974cab033/9524ebaa3b3e4889/res/aa8f243b-dc4f-4121-8606-e795730f72fd/skitch.png)

## Install

Grab the files which name begins with "CD" and copy them to your Xcode Swift project.

## Usage

1. Optional: tweak CDSettings class variables

2. Create color candidates from image

```  
let elton = NSImage(named: "elton")  
let colorDetector = ColorDetector()
let resized = colorDetector.resize(image)
let colorCandidates = colorDetector.getColorCandidatesFromImage(resized)
```  

## Todo

- Make a framework

- Make it iOS compatible

- Improve detector accuracy

- Improve post-detection adjustments

- Refactor pixel color detection

- Improve resize image speed