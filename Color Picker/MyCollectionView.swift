//
//  MyCollectionView.swift
//  Color Picker
//
//  Created by David Wu on 6/30/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

/// Allows an `NSCollectionViewItem` to delete itself from the collection view's backing model
class MyCollectionView: NSCollectionView {
    var collectionController: NSArrayController!

    /// Delete item's represented object from model controller
    func delete(_ item: NSCollectionViewItem) {
        guard let indexPath = self.indexPath(for: item) else { fatalError() }
        let indexSet = IndexSet([indexPath.item])
        collectionController.remove(atArrangedObjectIndexes: indexSet)
    }
}
