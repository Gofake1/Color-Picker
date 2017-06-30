//
//  PaletteCollectionViewItem.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var paletteColorsView: PaletteColorsView!

    override var nibName: NSNib.Name? {
        return NSNib.Name(rawValue: "PaletteCollectionViewItem")
    }

    override var representedObject: Any? {
        didSet {
            if let palette = representedObject as? Palette {
                paletteColorsView.bind(NSBindingName(rawValue: #keyPath(PaletteColorsView.colors)),
                                       to: palette,
                                       withKeyPath: #keyPath(Palette.colors),
                                       options: nil)
                paletteColorsView.needsDisplay = true
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? NSColor.white : NSColor.black
        }
    }

    override func awakeFromNib() {
        paletteColorsView.delegate = self
    }

    @IBAction func delete(_ sender: NSMenuItem) {
        guard let collectionView = collectionView as? MyCollectionView else { fatalError() }
        collectionView.delete(self)
    }
}

extension PaletteCollectionViewItem: PaletteColorsViewDelegate {
    func selectColor(_ color: NSColor) {
        ColorController.shared.setColor(color)
    }
}
