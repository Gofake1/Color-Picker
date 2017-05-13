//
//  PaletteCollectionViewItem.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var paletteColorsView: PaletteColorsView!

    override var nibName: String? {
        return "PaletteCollectionViewItem"
    }

    override var representedObject: Any? {
        didSet {
            if let palette = representedObject as? Palette {
                paletteColorsView.bind(#keyPath(PaletteColorsView.colors),
                                       to: palette,
                                       withKeyPath: #keyPath(Palette.colors),
                                       options: nil)
                paletteColorsView.needsDisplay = true
            }
        }
    }
}
