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
    var totalSeconds: Double = 25//1500
    var currentSeconds: Double = 25//1500
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    let pomodoroInstance: PomodoroTimer = PomodoroTimer()
    
    // Animation
    let shapeLayer = CAShapeLayer()
    
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
        totalSeconds = currentSeconds
        shapeLayer.strokeEnd = 0
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        playPauseButton.title = "Play"
    }
    
    // EVENT - Reset Interval clicked
    @IBAction func resetIntervalButtonClicked(_ sender: NSButton) {
        timer.invalidate()
        currentSeconds = pomodoroInstance.getCurrentIntervalTime()
        totalSeconds = currentSeconds
        shapeLayer.strokeEnd = 0
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
                totalSeconds = newInterval
                timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
            } else {
                timer.invalidate()
                // Show complete message
            }
        } else {
            currentSeconds -= 1;
            timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
            shapeLayer.strokeEnd = CGFloat((totalSeconds - currentSeconds) / totalSeconds)
        }
    }
    
    // Format time into display string
    func getTimeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds);
    }
    
    // Setup Initial tracks
    func setupInitialTracks() -> Void {
        let circularPath = NSBezierPath()
        circularPath.appendArc(withCenter: .zero, radius: CGFloat(125), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        // Track Layer #1
        let trackLayer = CAShapeLayer()
        let extraTrackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        extraTrackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = NSColor.lightGray.cgColor
        extraTrackLayer.strokeColor = NSColor.lightGray.cgColor
        trackLayer.lineWidth = 6
        extraTrackLayer.lineWidth = 6
        trackLayer.fillColor = NSColor.clear.cgColor
        extraTrackLayer.fillColor = NSColor.clear.cgColor
        extraTrackLayer.transform = CATransform3DMakeRotation((CGFloat.pi / 2), 0, 0, 1)
        trackLayer.position = CGPoint(x: 175, y: 200)
        extraTrackLayer.position = CGPoint(x: 175, y: 200)
        
        // Add track layers to view
        view.layer?.addSublayer(trackLayer)
        view.layer?.addSublayer(extraTrackLayer)
        
        // Setup progress
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = NSColor.red.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = NSColor.clear.cgColor
        //shapeLayer.lineCap = kCALineCapRound
        shapeLayer.position = CGPoint(x: 175, y: 200)
        shapeLayer.transform = CATransform3DMakeRotation((CGFloat.pi / 2), 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer?.addSublayer(shapeLayer)
    }
    
    // View has loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSeconds = pomodoroInstance.getCurrentIntervalTime()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        setupInitialTracks()
    }
}

// Add cgPath to NSBezierPath
extension NSBezierPath {
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .lineToBezierPathElement: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
            case .curveToBezierPathElement: path.addCurve(      to: CGPoint(x: points[2].x, y: points[2].y),
                                                                control1: CGPoint(x: points[0].x, y: points[0].y),
                                                                control2: CGPoint(x: points[1].x, y: points[1].y) )
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
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
