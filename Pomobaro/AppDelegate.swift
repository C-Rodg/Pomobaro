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

    // Main components
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover:NSPopover = NSPopover()
    var eventMonitor: EventMonitor?
    let menu: NSMenu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create taskbar image and click action
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("taskbar_default"))
            button.image?.isTemplate = true
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Create context menu
        constructMenu()
        
        // Assign view controller to popup content
        popover.contentViewController = TimerViewController.freshController()
        
        // Setup event monitoring --- DISABLED FOR NOW
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    // Status bar button clicked
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent {
            // Open context menu
            if event.type == NSEvent.EventType.rightMouseUp {
                closePopover(sender: nil)
                statusItem.menu = menu
                statusItem.popUpMenu(menu)
                statusItem.menu = nil
            } else {
                // Toggle popover view
                togglePopover(nil)
            }
        }
    }
    
    // Toggle popover view
    func togglePopover(_ sender: Any?) {
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
            eventMonitor?.start()
        }
    }
    
    // Close popover
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    // Open about page
    @objc func openAbout(_ sender: Any?) {
        if let url = URL(string: "https://curtisrodgers.com/"), NSWorkspace.shared.open(url) {
            
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // Create context menu
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "About Us", action: #selector(AppDelegate.openAbout(_:)), keyEquivalent: "A"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Pomobaro", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
}

