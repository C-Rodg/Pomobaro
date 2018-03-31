//
//  PomodoroTimer.swift
//  Pomobaro
//
//  Created by Curtis on 3/30/18.
//  Copyright © 2018 Curtis. All rights reserved.
//

import Cocoa

// Timer class
class PomodoroTimer {
    var currentIndex: Int = 0
    let timeArray: [TimeInterval] = [
        TimeInterval(timer: 1500, isBreak: false),
        TimeInterval(timer: 300, isBreak: true),
        TimeInterval(timer: 1500, isBreak: false),
        TimeInterval(timer: 300, isBreak: true),
        TimeInterval(timer: 1500, isBreak: false),
        TimeInterval(timer: 300, isBreak: true),
        TimeInterval(timer: 1500, isBreak: false),
        TimeInterval(timer: 900, isBreak: true)]
    
    
    // Reset entire timer
    func resetTimer() -> Void {
        currentIndex = 0
    }
    
    // Reset this interval
    func resetInterval() -> Void {
        // do something to reset time
    }
}

// Time interval
class TimeInterval {
    var isBreak: Bool
    var timer: Int
    
    init(timer: Int, isBreak: Bool) {
        self.timer = timer
        self.isBreak = isBreak
    }
}
