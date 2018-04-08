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
        PomodoroTimeInterval(timer: 15, isBreak: false),
        PomodoroTimeInterval(timer: 3, isBreak: true),
        PomodoroTimeInterval(timer: 15, isBreak: false),
        PomodoroTimeInterval(timer: 3, isBreak: true),
        PomodoroTimeInterval(timer: 15, isBreak: false),
        PomodoroTimeInterval(timer: 3, isBreak: true),
        PomodoroTimeInterval(timer: 15, isBreak: false),
        PomodoroTimeInterval(timer: 9, isBreak: true, isLongBreak: true)]
    
    
    // Reset entire timer
    func resetTimer() -> Int {
        currentIndex = 0
        pomodoroCount = 0
        return timeArray[currentIndex].timer
    }
    
    // Move to next interval
    func getNextInterval() -> Int? {
        if currentIndex + 1 >= timeArray.count {
            return nil
        } else {
            if !timeArray[currentIndex].isBreak {
                pomodoroCount += 1
            }
            currentIndex += 1
            return timeArray[currentIndex].timer
        }
    }
    
    // Get current interval
    func getCurrentIntervalTime() -> Int {
        return timeArray[currentIndex].timer
    }
}

// Time interval
class PomodoroTimeInterval {
    var isBreak: Bool
    var isLongBreak: Bool
    var timer: Int
    
    init(timer: Int, isBreak: Bool, isLongBreak: Bool = false) {
        self.timer = timer
        self.isBreak = isBreak
        self.isLongBreak = isLongBreak
    }
}
