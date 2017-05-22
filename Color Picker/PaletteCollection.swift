//
//  PaletteCollection.swift
//  Color Picker
//
//  Created by David Wu on 5/8/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

fileprivate let defaultPalettes = [
    Palette(name: "Rainbow",
            colors: [NSColor.red, NSColor.orange, NSColor.yellow, NSColor.green, NSColor.blue,
                     NSColor.purple]),
    Palette(name: "Grayscale",
            colors: [NSColor(red: 1, green: 1, blue: 1, alpha: 1),
                     NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1),
                     NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
                     NSColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1),
                     NSColor(red: 0, green: 0, blue: 0, alpha: 1)])
]

class PaletteCollection: NSObject, NSCoding {

    dynamic var palettes: [Palette]

    override init() {
        palettes = defaultPalettes
    }

    func addPalette(_ palette: Palette) {
        palettes.append(palette)
    }

    func restoreDefaults() {
        palettes = defaultPalettes
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        guard let palettes = aDecoder.decodeObject(forKey: "palettesArray") as? [Palette] else {
            // TODO: warn user about losing saved palettes
            self.palettes = []
            return
        }
        self.palettes = palettes
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(palettes, forKey: "palettesArray")
    }
}
