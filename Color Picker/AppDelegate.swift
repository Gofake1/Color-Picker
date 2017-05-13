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

    fileprivate lazy var colorPicker: NSWindowController? = {
        let colorPicker = NSStoryboard(name: "ColorPicker", bundle: nil).instantiateInitialController()
            as? NSWindowController
        colorPicker?.window?.isExcludedFromWindowsMenu = true
        return colorPicker
    }()

}

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let palettesData = UserDefaults.standard.data(forKey: "palettes") {
            paletteCollection = NSKeyedUnarchiver.unarchiveObject(with: palettesData) as! PaletteCollection
        } else {
            paletteCollection = PaletteCollection()
        }
        mainMenuController.colorPicker = colorPicker
        mainMenuController.palettesCollection = paletteCollection
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
