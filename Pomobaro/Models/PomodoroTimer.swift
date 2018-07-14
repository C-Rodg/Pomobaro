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
    
    // Indexes
    var currentIndex: Int = 0
    var pomodoroCount: Int = 0
    
    // Timers
    var timeWork: Double = 10
    var timeShortBreak: Double = 5
    var timeLongBreak: Double = 8
    
    var timeArray: [PomodoroTimeInterval] = []
    
    init() {
        generateTimeArray()
    }
    
    // Generate time array based off of current set intervals
    func generateTimeArray() {
        timeArray = []
        for i in 0...7 {
            if i == 7 {
                timeArray.append(PomodoroTimeInterval(timer: timeLongBreak, isBreak: true, isLongBreak: true))
            } else if i % 2 == 0 {
                timeArray.append(PomodoroTimeInterval(timer: timeWork, isBreak: false))
            } else {
                timeArray.append(PomodoroTimeInterval(timer: timeShortBreak, isBreak: true))
            }
        }
    }
    
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
    
    // Get Pomodoro Count
    func getPomodoroCount() -> Int {
        return pomodoroCount
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
