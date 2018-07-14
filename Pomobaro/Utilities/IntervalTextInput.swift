//
//  IntervalTextInput.swift
//  Pomobaro
//
//  Created by Curtis on 7/14/18.
//  Copyright © 2018 Curtis. All rights reserved.
//

import Cocoa

class IntervalTextInput: NSTextField {

    // Customize border
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let bounds: NSRect = self.bounds
        let border: NSBezierPath = NSBezierPath(roundedRect: NSInsetRect(bounds, 0.5, 0.5), xRadius: 3, yRadius: 3)
        NSColor.white.set()
        border.stroke()
    }
    
    // Control User Input
    override func textDidChange(_ obj: Notification) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "0123456789").inverted as NSCharacterSet
        self.stringValue =  (self.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
    
}
