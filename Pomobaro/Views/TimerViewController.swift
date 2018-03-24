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
    var seconds = 1500;
    var timer = Timer();
    var isTimerRunning = false;
    var resumeTapped = false;
    
    // Outlets
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var pauseButton: NSButton!
    
    // EVENT - Start timer button clicked
    @IBAction func startButtonClicked(_ sender: Any) {
        if isTimerRunning == false {
            runTimer()
            startButton.isEnabled = false
        }
    }
    
    // EVENT - Pause button clicked, toggling
    @IBAction func pauseButtonClicked(_ sender: Any) {
        if resumeTapped == false {
            timer.invalidate()
            resumeTapped = true
            pauseButton.title = "Resume"
        } else {
            runTimer()
            resumeTapped = false
            pauseButton.title = "Pause"
        }
    }
    
    
    // EVENT - Reset button clicked
    @IBAction func resetButtonClicked(_ sender: Any) {
        timer.invalidate()
        seconds = 1500
        timerLabel.stringValue = getTimeString(time: TimeInterval(seconds))
        isTimerRunning = false
        
        startButton.isEnabled = true
        pauseButton.title = "Pause"
        pauseButton.isEnabled = false
        resumeTapped = false
        
    }
    
    // Run Timer loop
    func runTimer() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
        
        isTimerRunning = true
        pauseButton.isEnabled = true
    }
    
    // Update the timer label view
    @objc func updateTimer() -> Void {
        if seconds < 1 {
            timer.invalidate()
            // SEND ALERT AND MOVE TO NEXT
        } else {
            seconds -= 1;
            timerLabel.stringValue = getTimeString(time: TimeInterval(seconds))
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
        
        pauseButton.isEnabled = false
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
