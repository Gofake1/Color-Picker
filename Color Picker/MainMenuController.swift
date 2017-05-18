//
//  MainMenuController.swift
//  Color Picker
//
//  Created by David Wu on 5/9/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class MainMenuController: NSObject {

    @IBOutlet weak var addToPaletteMenu: NSMenu!
    // Injected by AppDelegate
    weak var colorController: ColorController!
    weak var colorPicker: NSWindowController?
    weak var palettes: NSWindowController?
    weak var palettesCollection: PaletteCollection!

    override func awakeFromNib() {
        NSPasteboard.general().declareTypes([NSPasteboardTypeString], owner: self)
    }

    @IBAction func copyCurrentColorAsRGBHexadecimal(_ sender: NSMenuItem) {
        NSPasteboard.general().setString(colorController.selectedColor.rgbHexString,
                                         forType: NSPasteboardTypeString)
    }

    @IBAction func copyCurrentColorAsRGBDecimal(_ sender: NSMenuItem) {
        NSPasteboard.general().setString(colorController.selectedColor.rgbDecString,
                                         forType: NSPasteboardTypeString)
    }

    @IBAction func copyCurrentColorAsCYMK(_ sender: NSMenuItem) {
        NSPasteboard.general().setString(colorController.selectedColor.cmykString,
                                         forType: NSPasteboardTypeString)
    }

    @IBAction func showColorPicker(_ sender: NSMenuItem) {
        colorPicker?.showWindow(nil)
    }

    @IBAction func showPalettes(_ sender: NSMenuItem) {
        palettes?.showWindow(nil)
    }

    @IBAction func showPreferences(_ sender: NSMenuItem) {

    }

    func addColorToPalette(_ sender: NSMenuItem) {
        guard let palette = sender.representedObject as? Palette else { fatalError() }
        palette.addColor(colorController.selectedColor)
    }
}

extension MainMenuController: NSMenuDelegate {

    func menu(_ menu: NSMenu, update item: NSMenuItem, at index: Int, shouldCancel: Bool) -> Bool {
        if menu == addToPaletteMenu {
            item.action = #selector(addColorToPalette(_:))
            item.target = self
            item.title = palettesCollection.palettes[index].name
            item.representedObject = palettesCollection.palettes[index]
        }
        return true
    }

    func numberOfItems(in menu: NSMenu) -> Int {
        if menu == addToPaletteMenu {
            return palettesCollection.palettes.count
        }
        return 0
    }
}
