//
//  AppDelegate.swift
//  Color Picker
//
//  Created by David Wu on 5/4/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject {

    @IBOutlet weak var colorController: ColorController!
    @IBOutlet weak var mainMenuController: MainMenuController!
    var paletteCollection: PaletteCollection!

    fileprivate var colorPicker: NSWindowController? = {
        let colorPicker = NSStoryboard(name: "ColorPicker", bundle: nil).instantiateInitialController()
            as? NSWindowController
        colorPicker?.window?.isExcludedFromWindowsMenu = true
        return colorPicker
    }()

    fileprivate lazy var palettes: NSWindowController? = {
        let palettes = NSStoryboard(name: "Palettes", bundle: nil).instantiateInitialController()
            as? NSWindowController
        palettes?.window?.isExcludedFromWindowsMenu = true
        return palettes
    }()
}

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let palettesData = UserDefaults.standard.data(forKey: "palettes") {
            paletteCollection = NSKeyedUnarchiver.unarchiveObject(with: palettesData) as! PaletteCollection
        } else {
            paletteCollection = PaletteCollection()
        }

        mainMenuController.colorController    = colorController
        mainMenuController.colorPicker        = colorPicker
        mainMenuController.palettes           = palettes
        mainMenuController.palettesCollection = paletteCollection
        (colorPicker?.contentViewController as! ColorPickerViewController).colorController = colorController
        (palettes?.contentViewController as! PaletteViewController).paletteCollection = paletteCollection

        colorPicker?.showWindow(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: paletteCollection),
                                  forKey: "palettes")
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
