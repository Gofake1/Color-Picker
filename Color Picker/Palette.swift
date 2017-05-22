//
//  Palette.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class Palette: NSObject, NSCoding {

    dynamic var name: String
    dynamic var colors: Set<NSColor>
    let id: Int

    init(id: Int? = nil, name: String = "New Palette", colors: Set<NSColor> = Set()) {
        self.name = name
        self.colors = colors
        self.id = id ?? Date().hashValue
    }

    func addColor(_ color: NSColor) {
        colors.insert(color)
    }

    func removeColor(_ color: NSColor) {
        colors.remove(color)
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        id = aDecoder.decodeInteger(forKey: "id")
        let colorData = aDecoder.decodeObject(forKey: "colorDataArray") as! [Data]
        let colorArray = colorData.map { NSUnarchiver.unarchiveObject(with: $0) as! NSColor }
        colors = Set(colorArray)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        let encodedColors = colors.map { NSArchiver.archivedData(withRootObject: $0) }
        aCoder.encode(encodedColors, forKey: "colorDataArray")
    }
}
