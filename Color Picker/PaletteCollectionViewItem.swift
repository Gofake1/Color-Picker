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

    override var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? NSColor.white : NSColor.black
        }
    }

    @objc dynamic var isEditing = false

    override func awakeFromNib() {
        paletteColorsView.delegate = self
    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let action = menuItem.action else { return false }
        switch action {
        case #selector(edit(_:)):
            return !isEditing
        default:
            return true
        }
    }

    @IBAction func edit(_ sender: NSMenuItem) {
        isEditing = true
        paletteColorsView.state = .isEditing
    }

    @IBAction func delete(_ sender: NSMenuItem) {
        guard let collectionView = collectionView as? MyCollectionView else { fatalError() }
        collectionView.delete(self)
    }

    @IBAction func finishEditing(_ sender: NSButton) {
        isEditing = false
        paletteColorsView.state = .normal
    }

    deinit {
        paletteColorsView.unbind(#keyPath(PaletteColorsView.colors))
    }
}

extension PaletteCollectionViewItem: PaletteColorsViewDelegate {

    func selectColor(_ color: NSColor) {
        ColorController.shared.setColor(color)
    }

    func addColor(_ color: NSColor) {
        if let palette = representedObject as? Palette {
            palette.addColor(color)
        }
    }

    func removeColor(_ color: NSColor) {
        if let palette = representedObject as? Palette {
            palette.removeColor(color)
        }
    }
}
