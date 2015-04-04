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

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label1: NSTextField!
    @IBOutlet weak var label2: NSTextField!
    @IBOutlet weak var label3: NSTextField!
    @IBOutlet weak var label4: NSTextField!
    @IBOutlet weak var image: NSImageView!




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
//        let col1 = c.primaryColorCandidate!.colorUsingColorSpace(NSColorSpace.genericRGBColorSpace())
        label1.textColor = c.primaryColorCandidate!
        label2.textColor = c.secondaryColorCandidate!
        label3.textColor = c.detailColorCandidate!
        label4.textColor = c.backgroundColorCandidate!
        image.image = pic!
    }

}
