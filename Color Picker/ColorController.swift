//
//  ColorController.swift
//  Color Picker
//
//  Created by David Wu on 5/15/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

/// Publicly accessible interface of `ColorPickerViewController`; any class can use this class to indirectly
/// modify `ColorPickerViewController`'s state.
class ColorController {

    static var shared = ColorController()
    /// Should only be set by `colorPicker`. Other classes should use `setColor`.
    var selectedColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    // Injected by ColorPickerViewController
    weak var colorPicker: ColorPickerViewController!

    func setColor(_ color: NSColor) {
        selectedColor = color
        colorPicker.updateSelectedColor()
    }
}
