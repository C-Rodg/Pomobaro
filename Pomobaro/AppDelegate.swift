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
    
    // Right click menu
    let menu: NSMenu = NSMenu()
    lazy var myPlayMenuItem : NSMenuItem = {
        return NSMenuItem(title: "Play", action: #selector(AppDelegate.handlePlayPauseClick(_:)), keyEquivalent: "p")
    }()
    
    lazy var myPauseMenuItem : NSMenuItem = {
        return NSMenuItem(title: "Pause", action: #selector(AppDelegate.handlePlayPauseClick(_:)), keyEquivalent: "p")
    }()
    

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
        popover.contentViewController?.loadView()
        
        // Setup event monitoring
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
                calculateMenuItems()
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
    
    func calculateMenuItems() {
        if let vc = popover.contentViewController as? TimerViewController {
            if vc.isTimerRunning {
                myPlayMenuItem.isHidden = true
                myPauseMenuItem.isHidden = false
            } else {
                myPlayMenuItem.isHidden = false
                myPauseMenuItem.isHidden = true
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
            NSApp.activate(ignoringOtherApps: true)
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
    
    // Handle toggle of play pause
    @objc func handlePlayPauseClick(_ sender: Any?) {
        if let vc = popover.contentViewController as? TimerViewController {
            vc.playPauseButtonClicked(nil)
        }
    }
    
    // Handle reset one interval
    @objc func handleResetOneInterval(_ sender: Any?) {
        if let vc = popover.contentViewController as? TimerViewController {
            vc.resetIntervalButtonClicked(nil)
        }
    }
    
    // Handle reset all intervals
    @objc func handleResetAllIntervals(_ sender: Any?) {
        if let vc = popover.contentViewController as? TimerViewController {
            vc.resetIntervalButtonClicked(nil)
        }
    }


    // Create context menu
    func constructMenu() {
        menu.addItem(myPlayMenuItem)
        menu.addItem(myPauseMenuItem)
        myPauseMenuItem.isHidden = true
        menu.addItem(NSMenuItem(title: "Reset One", action: #selector(AppDelegate.handleResetOneInterval(_:)), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Reset All", action: #selector(AppDelegate.handleResetAllIntervals(_:)), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About Us", action: #selector(AppDelegate.openAbout(_:)), keyEquivalent: "A"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
}

