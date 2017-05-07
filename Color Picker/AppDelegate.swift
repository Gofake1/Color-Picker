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

    fileprivate lazy var colorPicker: NSWindowController? = {
        return NSStoryboard(name: "ColorPicker", bundle: nil).instantiateInitialController()
            as? NSWindowController
    }()

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        colorPicker?.showWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
