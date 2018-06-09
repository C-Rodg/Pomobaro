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
    var pomodoroCount: Int = 0
    let timeArray: [PomodoroTimeInterval] = [
//        PomodoroTimeInterval(timer: 1500, isBreak: false),
//        PomodoroTimeInterval(timer: 300, isBreak: true),
//        PomodoroTimeInterval(timer: 1500, isBreak: false),
//        PomodoroTimeInterval(timer: 300, isBreak: true),
//        PomodoroTimeInterval(timer: 1500, isBreak: false),
//        PomodoroTimeInterval(timer: 300, isBreak: true),
//        PomodoroTimeInterval(timer: 1500, isBreak: false),
//        PomodoroTimeInterval(timer: 900, isBreak: true, isLongBreak: true)]
        PomodoroTimeInterval(timer: 10, isBreak: false),
        PomodoroTimeInterval(timer: 5, isBreak: true),
        PomodoroTimeInterval(timer: 10, isBreak: false),
        PomodoroTimeInterval(timer: 5, isBreak: true),
        PomodoroTimeInterval(timer: 10, isBreak: false),
        PomodoroTimeInterval(timer: 5, isBreak: true),
        PomodoroTimeInterval(timer: 10, isBreak: false),
        PomodoroTimeInterval(timer: 8, isBreak: true, isLongBreak: true)]
    
    
    // Reset entire timer
    func resetTimer() -> PomodoroTimeInterval {
        currentIndex = 0
        pomodoroCount = 0
        return timeArray[currentIndex]
    }
    
    // Move to next interval
    func getNextInterval() -> PomodoroTimeInterval? {
        if currentIndex + 1 >= timeArray.count {
            return nil
        } else {
            if !timeArray[currentIndex].isBreak {
                pomodoroCount += 1
            }
            currentIndex += 1
            return timeArray[currentIndex]
        }
    }
    
    // Get current interval
    func getCurrentInterval() -> PomodoroTimeInterval {
        return timeArray[currentIndex]
    }
}

// Time interval
class PomodoroTimeInterval {
    var isBreak: Bool
    var isLongBreak: Bool
    var timer: Double
    
    init(timer: Double, isBreak: Bool, isLongBreak: Bool = false) {
        self.timer = timer
        self.isBreak = isBreak
        self.isLongBreak = isLongBreak
    }
}
