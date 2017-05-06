//
//  Color.swift
//  Color Picker
//
//  Created by David Wu on 5/5/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Foundation

struct RGB {
    var r: UInt8
    var g: UInt8
    var b: UInt8

    var cgColor: CGColor {
        return CGColor(red:   CGFloat(r)/CGFloat(UInt8.max),
                       green: CGFloat(g)/CGFloat(UInt8.max),
                       blue:  CGFloat(b)/CGFloat(UInt8.max),
                       alpha: 1)
    }

    init(h: CGFloat, s: CGFloat, v: CGFloat) {
        let h = h * 6
        let i = floor(h)
        let f = h - i
        let p = v * (1.0 - s)
        let q = v * (1.0 - s * f)
        let t = v * (1.0 - s * (1.0 - f))

        var r, g, b: CGFloat
        switch i {
        case 0:
            r = v
            g = t
            b = p
        case 1:
            r = q
            g = v
            b = p
        case 2:
            r = p
            g = v
            b = t
        case 3:
            r = p
            g = q
            b = v
        case 4:
            r = t
            g = p
            b = v
        default:
            r = v
            g = p
            b = q
        }
        self.r = UInt8(r*255)
        self.g = UInt8(g*255)
        self.b = UInt8(b*255)
    }

    init(coord: (x: Int, y: Int), origin: (x: Int, y: Int), brightness: CGFloat) {
        let angle      = atan2(CGFloat(origin.x - coord.x), CGFloat(origin.y - coord.y)) + CGFloat.pi
        let distance   = sqrt(pow(CGFloat(origin.x - coord.x), 2) + pow(CGFloat(origin.y - coord.y), 2))
        let hue        = max(min(angle / (CGFloat.pi * 2), 1), 0)
        let saturation = max(min(distance / CGFloat(origin.x), 1), 0)
        self.init(h: hue, s: saturation, v: brightness)
    }
}

struct HSV {
    var h: CGFloat
    var s: CGFloat
    var v: CGFloat

    init(r: CGFloat, g: CGFloat, b: CGFloat) {
        let minRgb = min(r, min(g, b))
        let maxRgb = max(r, max(g, b))
        if minRgb == maxRgb {
            self.h = 0
            self.s = 0
            self.v = maxRgb
        } else {
            let d: CGFloat = (r == minRgb) ? g - b : ((b == minRgb) ? r - g : b - r)
            let h: CGFloat = (r == minRgb) ? 3 : ((b == minRgb) ? 1 : 5)
            self.h = (h - d/(maxRgb - minRgb)) / 6
            self.s = (maxRgb - minRgb) / maxRgb
            self.v = maxRgb
        }
    }
}
