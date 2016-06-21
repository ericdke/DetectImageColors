//
//  DemoErrorTypes.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 20/08/2015.
//  Copyright © 2015 Eric Dejonckheere. All rights reserved.
//

enum DemoAppError: String, ErrorProtocol {
    case CouldNotLoadColorNamesFile = "ERROR: could not load color names file"
    case CouldNotSaveColorNamesFile = "ERROR: could not save color names file"
    case InvalidFilePath = "ERROR: invalid file path"
    case CouldNotLoadDemoImage = "ERROR: could not load demo image"
    case ColorDetectorFailed = "ERROR: the color detector failed for this request"
    case CouldNotProcessDownloadedData = "ERROR: could not process downloaded data"
    case CouldNotfindDefaultConfiguration = "ERROR: could not find default configuration"
    case CouldNotSetSlidersFromPreset = "ERROR: could not load or use preset"
}
