//
//  DemoErrorTypes.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

enum DemoAppError: String, Error {
    case couldNotLoadColorNamesFile = "ERROR: could not load color names file"
    case couldNotSaveColorNamesFile = "ERROR: could not save color names file"
    case invalidFilePath = "ERROR: invalid file path"
    case couldNotLoadDemoImage = "ERROR: could not load demo image"
    case colorDetectorFailed = "ERROR: the color detector failed for this request"
    case couldNotProcessDownloadedData = "ERROR: could not process downloaded data"
    case couldNotfindDefaultConfiguration = "ERROR: could not find default configuration"
    case couldNotSetSlidersFromPreset = "ERROR: could not load or use preset"
}
