//
//  AppController.swift
//  detectImageColors
//
//  Created by ERIC DEJONCKHEERE on 04/04/2015.
//  Copyright (c) 2015 Eric Dejonckheere. All rights reserved.
//

import Cocoa

class AppController: NSObject {

    var colorTunes: ColorTunes?
    let pic = NSImage(named: "mic")

    override init() {
        colorTunes = ColorTunes(image: pic!, size: NSMakeSize(120.0, 120.0))
        super.init()
//        println("initialized")
    }

    override func awakeFromNib() {
//        println("awake")
        let c = colorTunes!
        c.startAnalyze(pic!)
        println(c.primaryColorCandidate)
        println(c.secondaryColorCandidate)
        println(c.detailColorCandidate)
        println(c.backgroundColorCandidate)
    }

}
