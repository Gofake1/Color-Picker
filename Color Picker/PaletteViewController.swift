//
//  PaletteViewController.swift
//  Color Picker
//
//  Created by David Wu on 5/6/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PaletteViewController: NSViewController {

    @IBOutlet weak var collectionController: NSArrayController!
    @IBOutlet weak var collectionView: NSCollectionView!
    // Injected by AppDelegate
    dynamic weak var paletteCollection: PaletteCollection!

    override func viewDidLoad() {
        collectionView.register(PaletteCollectionViewItem.self, forItemWithIdentifier: "palette")
    }

    override func deleteBackward(_ sender: Any?) {
        collectionController.remove(atArrangedObjectIndexes: collectionView.selectionIndexes)
    }

    @IBAction func addPalette(_ sender: NSButton) {
        paletteCollection.addPalette(Palette())
    }

    @IBAction func updateSearchPredicate(_ sender: NSSearchField) {
        if sender.stringValue == "" {
            collectionController.filterPredicate = nil
        } else {
            collectionController.filterPredicate = NSPredicate(format: "name contains[cd] %@",
                                                               argumentArray: [sender.stringValue])
        }
    }
}
