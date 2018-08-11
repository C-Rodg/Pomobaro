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
    var timeWork: Double = 1500
    var timeShortBreak: Double = 300
    var timeLongBreak: Double = 900
    
    // Size
    var totalPomodoros: Int = 4
    
    var timeArray: [PomodoroTimeInterval] = []
    
    init() {
        getIntervalsFromDatabase()
        generateTimeArray()
    }
    
    // Get Intervals from saved location
    func getIntervalsFromDatabase() {
        let defaults = UserDefaults.standard
        let work = defaults.double(forKey: "pomoWork")
        let short = defaults.double(forKey: "pomoShort")
        let long = defaults.double(forKey: "pomoLong")
        let total = defaults.integer(forKey: "totalPomodoros")
        
        timeWork = work < 1.0 ? 1500 : work
        timeShortBreak = short < 1.0 ? 300 : short
        timeLongBreak = long < 1.0 ? 900 : long
        totalPomodoros = total < 1 ? 4 : total
    }
    
    // Generate time array based off of current set intervals
    func generateTimeArray() {
        timeArray = []
        let lastIndex:Int = totalPomodoros * 2
        for i in 0...(lastIndex-1) {
            if i == (lastIndex - 1) {
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
        generateTimeArray()
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
