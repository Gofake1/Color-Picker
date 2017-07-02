//
//  PaletteColorView.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

protocol PaletteColorsViewDelegate: class {
    func selectColor(_ color: NSColor)
    func removeColor(_ color: NSColor)
}

class PaletteColorsView: NSView {

    @objc dynamic var colors: Set<NSColor>! {
        didSet {
            sortedColors = colors.sorted(by: >)
            needsDisplay = true
        }
    }
    var isEditing = false {
        didSet {
            needsDisplay = true
        }
    }
    weak var delegate: PaletteColorsViewDelegate?
    private var selectedIndex: Int? {
        didSet {
            if oldValue != selectedIndex {
                needsDisplay = true
            }
        }
    }
    private var sortedColors: [NSColor]!

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext, let colors = sortedColors else { return }
        context.setLineWidth(1)
        context.setStrokeColor(CGColor(gray: 0.6, alpha: 0.8))

        if colors.count == 0 {
            for i in 0..<10 {
                context.stroke(CGRect(x: i*20+1, y: 1, width: 18, height: 18))
            }
        } else if colors.count < 10 {
            var ii = 0
            for (i, color) in colors.enumerated() {
                ii += 1
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: CGFloat(i*20)+0.5, y: 0.5, width: 19, height: 19))
            }
            for i in ii..<10 {
                context.stroke(CGRect(x: i*20+1, y: 1, width: 18, height: 18))
            }
        } else {
            for (i, color) in colors.enumerated() {
                guard i < 10 else { break }
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: CGFloat(i*20)+0.5, y: 0.5, width: 19, height: 19))
            }
        }

        guard let selectedIndex = selectedIndex else { return }
        context.setStrokeColor(CGColor(red: 0.1, green: 0.1, blue: 1.0, alpha: 1.0))
        context.stroke(CGRect(x: selectedIndex*20+1, y: 1, width: 18, height: 18))

        if isEditing && selectedIndex < colors.count {
            context.setStrokeColor(colors[selectedIndex].scaledBrightness > 0.5 ? CGColor.black : CGColor.white)
            context.setLineWidth(2)
            context.addLines(between: [CGPoint(x: selectedIndex*20+4, y: 16),
                                       CGPoint(x: selectedIndex*20+16, y: 4)])
            context.addLines(between: [CGPoint(x: selectedIndex*20+4, y: 4),
                                       CGPoint(x: selectedIndex*20+16, y: 16)])
            context.strokePath()
        }
    }

    private func index(for point: CGPoint) -> Int? {
        switch point.x {
        case 0..<20:    return 0
        case 20..<40:   return 1
        case 40..<60:   return 2
        case 60..<80:   return 3
        case 80..<100:  return 4
        case 100..<120: return 5
        case 120..<140: return 6
        case 140..<160: return 7
        case 160..<180: return 8
        case 180..<200: return 9
        default:        return nil
        }
    }

    // MARK: - Mouse

    override func mouseDown(with event: NSEvent) {
        guard let index = selectedIndex,
            sortedColors.count != 0,
            sortedColors.count >= index
            else { return }
        if isEditing {
            delegate?.removeColor(sortedColors[index])
        } else {
            delegate?.selectColor(sortedColors[index])
        }
    }

    override func mouseExited(with event: NSEvent) {
        selectedIndex = nil
    }

    override func mouseMoved(with event: NSEvent) {
        selectedIndex = index(for: convert(event.locationInWindow, from: nil))
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        addTrackingArea(NSTrackingArea(rect:     bounds,
                                       options:  [.activeAlways, .mouseEnteredAndExited, .mouseMoved],
                                       owner:    self,
                                       userInfo: nil))
    }
}
