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

    @IBOutlet weak var mainMenuController: MainMenuController!
    var paletteCollection: PaletteCollection!

    private var colorPicker: NSWindowController? = {
        let colorPicker = NSStoryboard(name: NSStoryboard.Name(rawValue: "ColorPicker"), bundle: nil).instantiateInitialController()
            as? NSWindowController
        colorPicker?.window?.isExcludedFromWindowsMenu = true
        return colorPicker
    }()

    private lazy var palettes: NSWindowController? = {
        let palettes = NSStoryboard(name: NSStoryboard.Name(rawValue: "Palettes"), bundle: nil).instantiateInitialController()
            as? NSWindowController
        palettes?.window?.isExcludedFromWindowsMenu = true
        return palettes
    }()

    private lazy var preferences: NSWindowController? = {
        let preferences = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil).instantiateInitialController()
            as? NSWindowController
        preferences?.window?.isExcludedFromWindowsMenu = true
        return preferences
    }()

    @IBAction func resetPalettes(_ sender: NSButton) {
        paletteCollection.restoreDefaults()
    }
}

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let palettesData = UserDefaults.standard.data(forKey: "palettes") {
            paletteCollection = NSKeyedUnarchiver.unarchiveObject(with: palettesData) as? PaletteCollection
        } else {
            paletteCollection = PaletteCollection()
        }

        mainMenuController.colorPicker        = colorPicker
        mainMenuController.palettes           = palettes
        mainMenuController.palettesCollection = paletteCollection
        mainMenuController.preferences        = preferences
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
