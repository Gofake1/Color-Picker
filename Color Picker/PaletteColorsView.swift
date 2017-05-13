//
//  PaletteColorView.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteColorsView: NSView {

    var colors: Set<NSColor>! {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext, let colors = colors else { return }
        context.setLineWidth(1)
        context.setStrokeColor(CGColor(gray: 0.6, alpha: 0.8))
        if colors.count == 0 {
            for i in 0..<10 {
                context.stroke(CGRect(x: i*20+1, y: 1, width: 18, height: 18))
            }
        } else if colors.count < 10 {
            var ii = 0
            for (i, color) in colors.enumerated() {
                ii += 1
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: CGFloat(i*20)+0.5, y: 0.5, width: 19, height: 19))
            }
            for i in ii..<10 {
                context.stroke(CGRect(x: i*20+1, y: 1, width: 18, height: 18))
            }
        } else {
            for (i, color) in colors.enumerated() {
                guard i < 10 else { break }
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: CGFloat(i*20)+0.5, y: 0.5, width: 19, height: 19))
            }
        }
    }
}
