//
//  ColorPickerViewController.swift
//  Color Picker
//
//  Created by David Wu on 5/4/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class ColorPickerViewController: NSViewController {

    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var colorWheelView: ColorWheelView!
    // Injected by AppDelegate
    weak var colorController: ColorController!

    override func viewDidLoad() {
        colorWheelView.delegate = self
    }

    /// - postcondition: Mutates `colorController.selectedColor`
    @IBAction func setBrightness(_ sender: NSSlider) {
        let brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        colorWheelView.brightness = brightness
        let oldColor = colorController.selectedColor
        let newColor = NSColor(calibratedHue: oldColor.hueComponent,
                               saturation: oldColor.saturationComponent,
                               brightness: brightness,
                               alpha: 1.0)
        colorController.selectedColor = newColor
        updateLabel(newColor)
    }

    fileprivate func updateLabel(_ color: NSColor, _ labelTextShouldChange: Bool = true) {
        colorLabel.backgroundColor = color
        if labelTextShouldChange {
            colorLabel.stringValue = "#\(color.rgbHexString)"
        }
        if color.scaledBrightness < 0.5 {
            colorLabel.textColor = NSColor.white
        } else {
            colorLabel.textColor = NSColor.black
        }
    }

    fileprivate func updateSlider(_ color: NSColor) {
        guard let sliderCell = brightnessSlider.cell as? GradientSliderCell else { fatalError() }
        sliderCell.colorA = NSColor(calibratedHue: color.hueComponent,
                                    saturation: color.saturationComponent,
                                    brightness: 1.0,
                                    alpha: 1.0)
        brightnessSlider.drawCell(sliderCell)
        brightnessSlider.doubleValue = brightnessSlider.maxValue - (Double(color.scaledBrightness) *
            brightnessSlider.maxValue)
    }
}

extension ColorPickerViewController: ColorWheelViewDelegate {
    /// - postcondition: Mutates `colorController.selectedColor`
    func colorDidChange(_ newColor: NSColor) {
        colorController.selectedColor = newColor
        updateLabel(newColor)
        updateSlider(newColor)
    }
}

extension ColorPickerViewController: NSControlTextEditingDelegate {

    private func validateControlString(_ string: String) -> Bool {
        // String must be 6 characters and only contain numbers and letters 'a' through 'f',
        // or 7 characters if the first character is '#'
        switch string.characters.count {
        case 6:
            guard string.containsOnlyHexCharacters() else { return false }
        case 7:
            guard string.hasPrefix("#") else { return false }
            var trimmed = string; trimmed.remove(at: trimmed.startIndex)
            guard trimmed.containsOnlyHexCharacters() else { return false }
        default:
            return false
        }
        return true
    }

    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        if control == colorLabel {
            guard let _obj = obj, let string = _obj as? String else { return false }
            return validateControlString(string)
        }
        return false
    }

    /// - postcondition: Mutates `colorController.selectedColor`
    override func controlTextDidEndEditing(_ obj: Notification) {
        let string = (obj.userInfo?["NSFieldEditor"] as! NSTextView).textStorage!.string
        let color = NSColor(hexString: string)
        colorController.selectedColor = color
        colorWheelView.setColor(color)
        updateLabel(color, false)
        updateSlider(color)
        view.window?.makeFirstResponder(view)
    }
}

extension String {
    func containsOnlyHexCharacters() -> Bool {
        return !characters.contains {
            switch $0 {
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "a", "b",
                 "c", "d", "e", "f":
                return false
            default:
                return true
            }
        }
    }
}
