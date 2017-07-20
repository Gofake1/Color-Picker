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
    @IBOutlet weak var collectionView: MyCollectionView!
    // Injected by AppDelegate
    @objc dynamic weak var paletteCollection: PaletteCollection!
    /// Cached index paths for dragged items in the current drag session
    fileprivate var draggedIndexPaths = Set<IndexPath>()

    override func awakeFromNib() {
        collectionView.collectionController = collectionController
        collectionView.register(PaletteCollectionViewItem.self,
                                forItemWithIdentifier: "palette")
        collectionView.register(forDraggedTypes: ["net.gofake1.Color-Picker.palette"])
    }

    override func deleteBackward(_ sender: Any?) {
        // TODO: ask for confirmation when deleting empty or multiple palettes
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

extension PaletteViewController: NSCollectionViewDelegate {

    func collectionView(_ collectionView: NSCollectionView,
                        pasteboardWriterForItemAt indexPath: IndexPath)
        -> NSPasteboardWriting? {
        let writer = NSPasteboardItem()
        let data = NSKeyedArchiver.archivedData(withRootObject: paletteCollection.palettes[indexPath.item])
        writer.setData(data, forType: "net.gofake1.Color-Picker.palette")
        return writer
    }

    func collectionView(_ collectionView: NSCollectionView,
                        draggingSession session: NSDraggingSession,
                        willBeginAt screenPoint: NSPoint,
                        forItemsAt indexPaths: Set<IndexPath>) {
        draggedIndexPaths = indexPaths
    }

    func collectionView(_ collectionView: NSCollectionView,
                        draggingSession session: NSDraggingSession,
                        endedAt screenPoint: NSPoint,
                        dragOperation operation: NSDragOperation) {
        draggedIndexPaths = []
    }

    func collectionView(_ collectionView: NSCollectionView,
                        validateDrop draggingInfo: NSDraggingInfo,
                        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
                        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionViewDropOperation>)
        -> NSDragOperation {
        return .move
    }

    func collectionView(_ collectionView: NSCollectionView,
                        acceptDrop draggingInfo: NSDraggingInfo,
                        indexPath: IndexPath,
                        dropOperation: NSCollectionViewDropOperation)
        -> Bool {
        for fromIndexPath in draggedIndexPaths {
            let temp = paletteCollection.palettes.remove(at: fromIndexPath.item)
            paletteCollection.palettes.insert(temp, at: (indexPath.item <= fromIndexPath.item)
                ? indexPath.item : indexPath.item-1)
        }
        return true
    }
}
