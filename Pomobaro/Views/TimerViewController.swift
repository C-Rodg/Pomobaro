//
//  TImerViewController.swift
//  Pomobaro
//
//  Created by Curtis on 3/22/18.
//  Copyright © 2018 Curtis. All rights reserved.
//

import Cocoa

class TimerViewController: NSViewController {

    // Timer Settings and flags
    var currentSeconds = 1500;
    var timer = Timer();
    var isTimerRunning = false;
    var resumeTapped = false;
    let pomodoroInstance: PomodoroTimer = PomodoroTimer()
    
    
    // Outlets
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var playPauseButton: NSButton!
    
    // EVENT - Play/pause button clicked
    @IBAction func playPauseButtonClicked(_ sender: Any) {
        if isTimerRunning == false {
            runTimer()
            playPauseButton.title = "Pause"
        } else {
            timer.invalidate()
            playPauseButton.title = "Play"
            isTimerRunning = false
        }
    }
    
    
    // EVENT - Reset All clicked
    @IBAction func resetButtonClicked(_ sender: Any) {
        timer.invalidate()
        currentSeconds = pomodoroInstance.resetTimer()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        playPauseButton.title = "Play"
    }
    
    // EVENT - Reset Interval clicked
    @IBAction func resetIntervalButtonClicked(_ sender: NSButton) {
        timer.invalidate()
        currentSeconds = pomodoroInstance.getCurrentIntervalTime()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        playPauseButton.title = "Play"
    }
    
    // Run Timer loop
    func runTimer() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
        
        isTimerRunning = true
    }
    
    // Update the timer label view
    @objc func updateTimer() -> Void {
        if currentSeconds < 1 {
            if let newInterval = pomodoroInstance.getNextInterval() {
                currentSeconds = newInterval
                timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
            } else {
                timer.invalidate()
                // Show complete message
            }
        } else {
            currentSeconds -= 1;
            timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        }
    }
    
    // Format time into display string
    func getTimeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds);
    }
    
    // View has loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSeconds = pomodoroInstance.getCurrentIntervalTime()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
    }
    
}

// Create view controller for taskbar application
extension TimerViewController {
    static func freshController() -> TimerViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "TimerViewController")
        guard let vc = storyboard.instantiateController(withIdentifier: identifier) as? TimerViewController else {
            fatalError("Cannot find TimerViewController - check Main.storyboard")
        }
        return vc
    }
}
