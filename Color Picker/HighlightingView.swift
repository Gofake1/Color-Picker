//
//  HighlightingView.swift
//  Color Picker
//
//  Created by David Wu on 5/13/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class HighlightingView: NSView {

    var highlightColor: NSColor = NSColor.alternateSelectedControlColor
    var shouldHighlight = false {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        if shouldHighlight {
            highlightColor.set()
        } else {
            NSColor.clear.set()
        }
        NSRectFill(dirtyRect)
    }
}
