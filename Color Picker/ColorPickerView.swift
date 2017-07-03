//
//  ColorPickerView.swift
//  Color Picker
//
//  Created by David Wu on 7/2/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class ColorPickerView: NSView {

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }
}
