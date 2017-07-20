//
//  ColorDragView.swift
//  Color Picker
//
//  Created by David Wu on 7/7/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

/// Allows colors to be dragged out
class ColorDragView: NSImageView {

    override func mouseDown(with event: NSEvent) {
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setDataProvider(self, forTypes: [NSPasteboardTypeColor])
        let draggingImage = NSImage(size: bounds.size)
        draggingImage.lockFocus()
        ColorController.shared.selectedColor.drawSwatch(in: bounds)
        draggingImage.unlockFocus()
        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(bounds, contents: draggingImage)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
}

extension ColorDragView: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession,
                         sourceOperationMaskFor context: NSDraggingContext)
        -> NSDragOperation {
        return .generic
    }
}

extension ColorDragView: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?, 
                    item: NSPasteboardItem,
                    provideDataForType type: String) {
        guard let pasteboard = pasteboard, type == NSPasteboardTypeColor else { return }
        ColorController.shared.selectedColor.write(to: pasteboard)
    }
}
