//
//  EventMonitor.swift
//  Pomobaro
//
//  Created by Curtis on 3/23/18.
//  Copyright © 2018 Curtis. All rights reserved.
//

import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    // Remove monitors
    deinit {
        stop()
    }
    
    // Monitor for events
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    // Stop watching for events
    public func stop() {
        if let unwrappedMonitor = monitor {
            NSEvent.removeMonitor(unwrappedMonitor)
            monitor = nil
        }
    }
}
