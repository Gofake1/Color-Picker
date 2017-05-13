//
//  PaletteCollection.swift
//  Color Picker
//
//  Created by David Wu on 5/8/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteCollection: NSObject, NSCoding {

    dynamic var palettes: [Palette]

    override init() {
        palettes = [
            Palette(name: "Rainbow",
                    colors: [NSColor.red, NSColor.orange, NSColor.yellow, NSColor.green, NSColor.blue,
                             NSColor.purple]),
            Palette(name: "Grayscale",
                    colors: [NSColor.white, NSColor.gray, NSColor.black])
        ]
        super.init()
    }

    func addPalette(_ palette: Palette) {
        palettes.append(palette)
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
