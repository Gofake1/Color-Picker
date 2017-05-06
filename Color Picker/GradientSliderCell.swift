//
//  GradientSliderCell.swift
//  Color Picker
//
//  Created by David Wu on 5/5/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class GradientSliderCell: NSSliderCell {

    var colorA = NSColor.white
    var colorB = NSColor.black
    private var barImage: CGImage?
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        NSGradient(starting: colorA, ending: colorB)?.draw(in: rect, angle: 0)
    }
}
