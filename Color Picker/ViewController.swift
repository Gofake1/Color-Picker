//
//  ViewController.swift
//  Color Picker
//
//  Created by David Wu on 5/4/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var colorLabel: NSTextField!
    @IBOutlet weak var colorWheelView: ColorWheelView!

    override func viewDidLoad() {
        colorWheelView.delegate = self
    }

    @IBAction func setBrightness(_ sender: NSSlider) {
        let brightness = CGFloat((sender.maxValue-sender.doubleValue) / sender.maxValue)
        updateColorWheel(brightness)
        updateLabel(brightness)
    }

    private func updateColorWheel(_ brightness: CGFloat) {
        colorWheelView.brightness = brightness
    }

    fileprivate func updateColorWheel(_ color: NSColor) {
        colorWheelView.setColor(color)
    }

    private func updateLabel(_ brightness: CGFloat) {
        let masterColor = NSColor(cgColor: colorWheelView.selectedColor)!
        let newColor = NSColor(calibratedHue: masterColor.hueComponent,
                               saturation: masterColor.saturationComponent,
                               brightness: brightness,
                               alpha: 1.0)
        updateLabel(newColor)
    }

    fileprivate func updateLabel(_ color: NSColor, _ labelTextShouldChange: Bool = true) {
        colorLabel.backgroundColor = color
        if labelTextShouldChange {
            colorLabel.stringValue = "#\(color.hexString)"
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

extension ViewController: ColorWheelViewDelegate {
    func colorDidChange(_ newColor: CGColor) {
        guard let color = NSColor(cgColor: newColor) else { fatalError() }
        updateLabel(color)
        updateSlider(color)
    }
}

extension ViewController: NSControlTextEditingDelegate {

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

    override func controlTextDidEndEditing(_ obj: Notification) {
        let string = (obj.userInfo?["NSFieldEditor"] as! NSTextView).textStorage!.string
        let color = NSColor(hexString: string)
        updateColorWheel(color)
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
