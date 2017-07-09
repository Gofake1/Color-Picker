//
//  ColorPickerView.swift
//  Color Picker
//
//  Created by David Wu on 7/2/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

/// `ColorPickerViewController` content view. Allows colors to be dragged in.
class ColorPickerView: NSView {

    override func awakeFromNib() {
        registerForDraggedTypes([.color])
    }

    // MARK: - NSDraggingDestination

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
            colors.count > 0
            else { return false }
        // Cancel if dragged color is the same as the current color
        return ColorController.shared.selectedColor != colors[0]
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        guard let colors = pasteboard.readObjects(forClasses: [NSColor.self], options: nil) as? [NSColor],
            colors.count > 0
            else { return false }
        ColorController.shared.setColor(colors[0])
        return true
    }

    // MARK: -

    // Allows mouse click to lose `ColorPickerViewController`'s text field's focus
    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }
}
