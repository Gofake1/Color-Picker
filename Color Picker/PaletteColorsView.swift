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
    func addColor(_ color: NSColor)
    func removeColor(_ color: NSColor)
}

/// Allows colors to be dragged in and out
class PaletteColorsView: NSView {

    enum State {
        case isDraggingOut
        case isEditing
        case normal
    }

    @objc dynamic var colors: Set<NSColor>! {
        didSet {
            sortedColors = colors.sorted(by: >)
            needsDisplay = true
        }
    }
    weak var delegate: PaletteColorsViewDelegate?
    var state = State.normal {
        didSet {
            switch state {
            case .isEditing:
                needsDisplay = true
            default:
                break
            }
        }
    }
    fileprivate var draggedOutColor: NSColor?
    private var selectedIndex: Int? {
        didSet {
            if oldValue != selectedIndex {
                needsDisplay = true
            }
        }
    }
    private var sortedColors: [NSColor]!

    override func awakeFromNib() {
        register(forDraggedTypes: [NSPasteboardTypeColor])
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current()?.cgContext, let colors = sortedColors else { return }
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

        // Draw 'X' on selected color swatch if in editing mode
        if state == .isEditing && selectedIndex < colors.count {
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
        guard bounds.contains(point) else { return nil }
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

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard state == .normal else { return [] }
        // Ignore drags from self
        if let paletteColorsView = sender.draggingSource() as? PaletteColorsView,
            paletteColorsView == self {
            return []
        }
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
            colors.count > 0
            else { return false }
        delegate?.addColor(colors[0])
        return true
    }

    // MARK: - Mouse

    override func mouseDragged(with event: NSEvent) {
        guard state == .normal,
            let index = selectedIndex,
            sortedColors.count != 0,
            sortedColors.count > index
            else { return }
        state = .isDraggingOut
        draggedOutColor = sortedColors[index]
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setDataProvider(self, forTypes: [NSPasteboardTypeColor])
        let draggingImage = NSImage(size: NSSize(width: 18, height: 18))
        draggingImage.lockFocus()
        sortedColors[index].drawSwatch(in: NSRect(x: 0, y: 0, width: 18, height: 18))
        draggingImage.unlockFocus()
        let dragPoint = convert(event.locationInWindow, from: nil)
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(NSRect(x: dragPoint.x-11, y: dragPoint.y-6, width: 18, height: 18),
                                      contents: draggingImage)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

    override func mouseUp(with event: NSEvent) {
        guard let index = selectedIndex,
            sortedColors.count != 0,
            sortedColors.count > index
            else { return }
        switch state {
        case .isDraggingOut:
            return
        case .isEditing:
            delegate?.removeColor(sortedColors[index])
        case .normal:
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

extension PaletteColorsView: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext)
        -> NSDragOperation {
        return .generic
    }

    func draggingSession(_ session: NSDraggingSession,
                         endedAt screenPoint: NSPoint,
                         operation: NSDragOperation) {
        state = .normal
        draggedOutColor = nil
    }
}

extension PaletteColorsView: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?,
                    item: NSPasteboardItem,
                    provideDataForType type: String) {
        guard let pasteboard = pasteboard,
            let color = draggedOutColor,
            type == NSPasteboardTypeColor
            else { return }
        color.write(to: pasteboard)
    }
}
