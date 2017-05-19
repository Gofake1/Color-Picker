//
//  PaletteColorView.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteColorsView: NSView {

    var colors: Set<NSColor>! {
        didSet {
            sortedColors = colors.sorted(by: >)
        }
    }
    private var selectedIndex: Int? {
        didSet {
            if oldValue != selectedIndex {
                needsDisplay = true
            }
        }
    }
    private var sortedColors: [NSColor]! {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext, let colors = colors else { return }
        context.setLineWidth(1)
        context.setStrokeColor(CGColor(gray: 0.6, alpha: 0.8))
        if colors.count == 0 {
            for i in 0..<10 {
                context.stroke(CGRect(x: i*20+1, y: 1, width: 18, height: 18))
            }
        } else if colors.count < 10 {
            var ii = 0
            for (i, color) in sortedColors.enumerated() {
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
        if let selectedIndex = selectedIndex {
            context.setStrokeColor(CGColor(red: 0.1, green: 0.1, blue: 1.0, alpha: 1.0))
            context.stroke(CGRect(x: selectedIndex*20+1, y: 1, width: 18, height: 18))
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

    override func mouseExited(with event: NSEvent) {
        selectedIndex = nil
    }

    override func mouseMoved(with event: NSEvent) {
        selectedIndex = index(for: convert(event.locationInWindow, from: nil))
    }

    override func updateTrackingAreas() {
        for area in trackingAreas {
            removeTrackingArea(area)
        }
        addTrackingArea(NSTrackingArea(rect:     bounds,
                                       options:  [.activeAlways, .mouseEnteredAndExited, .mouseMoved],
                                       owner:    self,
                                       userInfo: nil))
    }
}
