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

    override func viewDidLoad() {
        ColorController.shared.colorPicker = self
        colorWheelView.delegate = self
    }

    /// Should only be called by `colorController`
    func updateSelectedColor() {
        updateColorWheel()
        updateLabel()
        updateSlider()
    }

    /// - postcondition: Mutates `ColorController.brightness`
    @IBAction func setBrightness(_ sender: NSSlider) {
        ColorController.shared.brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        updateColorWheel(crosshairShouldChange: false)
        updateLabel()
    }

    fileprivate func updateColorWheel(crosshairShouldChange: Bool = true) {
        colorWheelView.setColor(ColorController.shared.selectedColor, crosshairShouldChange)
    }

    fileprivate func updateLabel(labelTextShouldChange: Bool = true) {
        colorLabel.backgroundColor = ColorController.shared.selectedColor
        if labelTextShouldChange {
            colorLabel.stringValue = "#\(ColorController.shared.selectedColor.rgbHexString)"
        }
        if ColorController.shared.selectedColor.scaledBrightness < 0.5 {
            colorLabel.textColor = NSColor.white
        } else {
            colorLabel.textColor = NSColor.black
        }
    }

    fileprivate func updateSlider() {
        guard let sliderCell = brightnessSlider.cell as? GradientSliderCell else { fatalError() }
        sliderCell.colorA = ColorController.shared.masterColor
        brightnessSlider.drawCell(sliderCell)
        brightnessSlider.doubleValue = brightnessSlider.maxValue - (Double(ColorController.shared.brightness) *
            brightnessSlider.maxValue)
    }
}

extension ColorPickerViewController: ColorWheelViewDelegate {
    /// - postcondition: Mutates `ColorController.masterColor`
    func colorDidChange(_ newColor: NSColor) {
        ColorController.shared.masterColor = newColor
        updateLabel()
        updateSlider()
    }
}

extension ColorPickerViewController: NSControlTextEditingDelegate {

    private func validateControlString(_ string: String) -> Bool {
        // String must be 6 characters and only contain numbers and letters 'a' through 'f',
        // or 7 characters if the first character is '#'
        switch string.characters.count {
        case 6:
            guard string.containsOnlyHexCharacters() else { return false }
            return true
        case 7:
            guard string.hasPrefix("#") else { return false }
            var trimmed = string; trimmed.remove(at: trimmed.startIndex)
            guard trimmed.containsOnlyHexCharacters() else { return false }
            return true
        default:
            return false
        }
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
        ColorController.shared.selectedColor = color
        updateColorWheel()
        updateLabel(labelTextShouldChange: false)
        updateSlider()

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
