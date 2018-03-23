//
//  AppDelegate.swift
//  Pomobaro
//
//  Created by Curtis on 3/21/18.
//  Copyright © 2018 Curtis. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create taskbar image and click action
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("TaskBarImage"))
            button.action = #selector(togglePopover(_:))
        }
        
        popover.contentViewController = TimerViewController.freshController()
    }
    
    // Taskbar button clicked
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    // Show popover
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    // Close popover
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    @objc func printQuote(_ sender: Any?) {
        let quote = "Great quote here.."
        let author = "Curtis"
        print("\(quote) by \(author)")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // Create context menu
    func constructMenu() -> Void {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Pomobaro", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        // TODO: Add 'About' that links to site
        statusItem.menu = menu
    }
}

