//
//  ColorController.swift
//  Color Picker
//
//  Created by David Wu on 5/15/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

/// Public interface of `ColorPickerViewController`; any class can use this class to indirectly
/// modify `ColorPickerViewController`'s state.
class ColorController {

    static var shared = ColorController()
    // Should only be set by `colorPicker`'s `NSSlider`. Affects `selectedColor`.
    var brightness: CGFloat = 1.0 {
        didSet {
            selectedColor = NSColor(calibratedHue: masterColor.hueComponent,
                                    saturation: masterColor.saturationComponent,
                                    brightness: brightness,
                                    alpha: 1.0)
        }
    }
    // Should only be set by `colorPicker`'s `ColorWheelView`. Affects `selectedColor`.
    var masterColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            selectedColor = NSColor(calibratedHue: masterColor.hueComponent,
                                    saturation: masterColor.saturationComponent,
                                    brightness: selectedColor.brightnessComponent,
                                    alpha: 1.0)
        }
    }
    var selectedColor = NSColor(calibratedRed: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    // Injected by ColorPickerViewController
    weak var colorPicker: ColorPickerViewController!

    /// - postcondition: Mutates `colorPicker`
    func setColor(_ color: NSColor) {
        selectedColor = color
        brightness = color.scaledBrightness
        masterColor = NSColor(calibratedHue: color.hueComponent,
                              saturation: color.saturationComponent,
                              brightness: 1.0,
                              alpha: 1.0)
        colorPicker.updateSelectedColor()
    }
}
