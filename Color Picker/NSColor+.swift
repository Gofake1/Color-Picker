//
//  NSColor+.swift
//  Color Picker
//
//  Created by David Wu on 5/5/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

extension NSColor {

    var rgbHexString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else { return "FFFFFF" }
        let r = Int(round(rgbColor.redComponent * 0xFF))
        let g = Int(round(rgbColor.greenComponent * 0xFF))
        let b = Int(round(rgbColor.blueComponent * 0xFF))
        return String(format: "%02X%02X%02X", r, g, b)
    }

    var rgbDecString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else { return "1.0 1.0 1.0" }
        return "\(rgbColor.redComponent) \(rgbColor.greenComponent) \(rgbColor.blueComponent)"
    }

    var cmykString: String {
        guard let cmykColor = usingColorSpaceName(NSColorSpaceName.deviceCMYK) else { return "0.0 0.0 0.0 0.0" }
        return "\(cmykColor.cyanComponent) \(cmykColor.magentaComponent) \(cmykColor.yellowComponent) " +
            "\(cmykColor.blackComponent)"
    }

    // Workaround: `NSColor`'s `brightnessComponent` is sometimes a value in [0-255] instead of in [0-1]
    /// Brightness value scaled between 0 and 1
    var scaledBrightness: CGFloat {
        if brightnessComponent > 1.0 {
            return brightnessComponent/255.0
        } else {
            return brightnessComponent
        }
    }

    /// - precondition: `hexString` contains six characters or seven if prefixed with `#`
    convenience init(hexString: String) {
        var hexString = hexString
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        guard let hexInt = Int(hexString, radix: 16) else {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }
        self.init(red:   CGFloat((hexInt >> 16) & 0xFF) / 255.0,
                  green: CGFloat((hexInt >> 8) & 0xFF) / 255.0,
                  blue:  CGFloat((hexInt >> 0) & 0xFF) / 255.0,
                  alpha: 1)
    }

    convenience init(coord: (x: Int, y: Int), center: (x: Int, y: Int), brightness: CGFloat) {
        let angle      = atan2(CGFloat(center.x - coord.x), CGFloat(center.y - coord.y)) + CGFloat.pi
        let distance   = sqrt(pow(CGFloat(center.x - coord.x), 2) + pow(CGFloat(center.y - coord.y), 2))
        let hue        = max(min(angle / (CGFloat.pi * 2), 1), 0)
        let saturation = max(min(distance / CGFloat(center.x), 1), 0)
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}

extension NSColor: Comparable {
    public static func < (lhs: NSColor, rhs: NSColor) -> Bool {
        if lhs.hueComponent == rhs.hueComponent {
            return lhs.brightnessComponent < rhs.brightnessComponent
        } else {
            return lhs.hueComponent < rhs.hueComponent
        }
    }
}
