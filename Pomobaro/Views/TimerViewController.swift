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
    var currentSeconds: Double = 10//1500
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    let pomodoroInstance: PomodoroTimer = PomodoroTimer()
    var currentPomodoroInterval: PomodoroTimeInterval = PomodoroTimeInterval(timer: 15, isBreak: false)
    
    // Animation
    let shapeLayer = CAShapeLayer()
    var pomoIndicators: [CAShapeLayer] = []
    
    // Outlets
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var resetIntervalButton: NSButton!
    @IBOutlet weak var resetAllButton: NSButton!
    
    // Initial Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the background
        createGradientBackground()
        
        // Get inital values
        currentPomodoroInterval = pomodoroInstance.getCurrentInterval()
        currentSeconds = currentPomodoroInterval.timer
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        setupInitialTracks()
        
        // Allow Notifications
        NSUserNotificationCenter.default.delegate = self
    }
    
    // Setup Initial tracks
    func setupInitialTracks() -> Void {
        let circularPath = NSBezierPath()
        circularPath.appendArc(withCenter: .zero, radius: CGFloat(125), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        circularPath.close()
        
        // Track Layer #1
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = color(from: "e5e5e5")//NSColor.lightGray.cgColor
        trackLayer.lineWidth = 6
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.position = CGPoint(x: 175, y: 200)
        
        // Add track layers to view
        view.layer?.addSublayer(trackLayer)
        
        // Setup progress
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = color(from : ColorTheme.blue.rawValue)
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = NSColor.clear.cgColor
        //shapeLayer.lineCap = kCALineCapRound
        shapeLayer.position = CGPoint(x: 175, y: 200)
        shapeLayer.transform = CATransform3DMakeRotation((CGFloat.pi / 2), 0, 0, 1)
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.fillMode = kCAFillModeForwards
        view.layer?.addSublayer(shapeLayer)
        
        // Create indicators
        createPomodoroIndicators()
    }
    
    // Create the gradient background
    func createGradientBackground() {
        let backgroundView = NSView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        let colorTop = color(from: "1e3148")
        let colorBottom = color(from: "141E30")
        let gradient  = CAGradientLayer()
        gradient.colors = [colorBottom, colorTop]
        gradient.locations = [ 0.1, 1.0]
        gradient.frame = backgroundView.bounds
        backgroundView.wantsLayer = true
        backgroundView.layer?.insertSublayer(gradient, at: 0)
        backgroundView.layer?.zPosition = -1
        
        view.addSubview(backgroundView)
    }
    
    // Generate pomodoro indicators
    func createPomodoroIndicators() {
        let xPaths: [Int] = [144, 164, 184, 204]
        for x in xPaths {
            let circularPath = NSBezierPath()
            circularPath.appendArc(withCenter: .zero, radius: CGFloat(6), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
            circularPath.close()
            
            let trackLayer = CAShapeLayer()
            trackLayer.path = circularPath.cgPath
            trackLayer.lineWidth = 2
            trackLayer.fillColor = NSColor.clear.cgColor
            trackLayer.strokeColor = color(from: ColorTheme.blue.rawValue, withAlpha: 0.4)
            trackLayer.position = CGPoint(x: x, y: 135)
            view.layer?.addSublayer(trackLayer)
            pomoIndicators.append(trackLayer)
        }
    }
    
    
    // Switch pomodoro indicator colors from break to no break
    func changePomodoroColor(_ isBreak: Bool) {
        for pomo in pomoIndicators {
            var instanceColor = ColorTheme.blue.rawValue
            if isBreak {
                instanceColor = ColorTheme.red.rawValue
            }
            if pomo.fillColor?.alpha == CGColor.clear.alpha {
                pomo.strokeColor = color(from: instanceColor, withAlpha: 0.4)
            } else {
                pomo.strokeColor = color(from: instanceColor)
                pomo.fillColor = color(from: instanceColor)
            }
        }
    }
    
    // Reset Pomodor indicators
    func resetPomodoroIndicators() {
        for pomo in pomoIndicators {
            pomo.removeAllAnimations()
            pomo.fillColor = CGColor.clear
            pomo.strokeColor = color(from: ColorTheme.blue.rawValue, withAlpha: 0.4)
        }
    }
    
    // Add pulsing and fill effect
    func completeIndividualPomoIndicator(count: Int) {
        animatePomoIndicator(for: count-1, with: ColorTheme.blue.rawValue)
    }
    
    // Helper animation for pomo indicators
    func animatePomoIndicator(for i: Int, with stringColor: String) {
        let indicator = pomoIndicators[i]
        indicator.fillColor = color(from: stringColor)
        indicator.strokeColor = color(from: stringColor)
        let animationScale = CABasicAnimation(keyPath: "transform.scale")
        animationScale.toValue = 1.3
        animationScale.duration = 0.7
        animationScale.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationScale.autoreverses = true
        animationScale.repeatCount = 3
        
        indicator.add(animationScale, forKey: "pulsing")
    }
    
    // All pomodoros are completed
    func completeAllPomoIndicitator() {
        for index in 0..<pomoIndicators.count {
            animatePomoIndicator(for: index, with: "2ecc71")
        }
    }
    
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
        playPauseButton.isHidden = false
        resetIntervalButton.isHidden = false
        resetAllButton.title = "Reset All"
        resetPomodoroIndicators()
        
        timer.invalidate()
        currentPomodoroInterval = pomodoroInstance.resetTimer()
        currentSeconds = currentPomodoroInterval.timer
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeColor = getTrackColor()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        playPauseButton.title = "Play"
    }
    
    // EVENT - Reset Interval clicked
    @IBAction func resetIntervalButtonClicked(_ sender: NSButton) {
        timer.invalidate()
        currentPomodoroInterval  = pomodoroInstance.getCurrentInterval()
        currentSeconds = currentPomodoroInterval.timer
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeColor = getTrackColor()
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
        if currentSeconds >= 1 {
            if currentSeconds == currentPomodoroInterval.timer {
                shapeLayer.opacity = 1
            }
            // Update progress path and label
            currentSeconds -= 1;
            timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
            let strokeEndValue = ((currentPomodoroInterval.timer - currentSeconds) / currentPomodoroInterval.timer)
            shapeLayer.strokeEnd = CGFloat(strokeEndValue)
        } else {
            // Timer complete, get next interval if available
            if let newInterval = pomodoroInstance.getNextInterval() {
                let isBreak = newInterval.isBreak
                // Update view
                currentPomodoroInterval = newInterval
                currentSeconds = newInterval.timer
                timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
                shapeLayer.opacity = 0
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                shapeLayer.strokeEnd = CGFloat(0)
                CATransaction.commit()
                shapeLayer.strokeColor = getTrackColor()
                
                // Show notifications and update indicators
                let pomodoroCount = pomodoroInstance.getPomodoroCount()
                var title = "Back to Work!"
                var msg = "Break is over. Let's get back to work."
                
                // Set Notification mesage
                if isBreak {
                    title = "Short Break!"
                    if (pomodoroCount == 1) {
                        msg = "1 pomodoro down. Let's take a short break."
                    } else if newInterval.isLongBreak {
                        title = "Long Break!"
                        msg = "4 pomodoros down. Let's take a long break."
                    } else {
                        msg = "\(pomodoroCount) pomodoros down. Let's take another short break."
                    }
                    completeIndividualPomoIndicator(count: pomodoroCount)
                }
                showNotification(withTitle: title, withBody: msg)
                changePomodoroColor(isBreak)
            } else {
                // Stop timer completely
                timer.invalidate()
                playPauseButton.isHidden = true
                resetIntervalButton.isHidden = true
                resetAllButton.title = "Restart"
                isTimerRunning = false
                
                showNotification(withTitle: "Timer Complete!", withBody: "Long break is over. Back to work.")
                shapeLayer.strokeColor = color(from: ColorTheme.green.rawValue)
                completeAllPomoIndicitator()
            }
        }
    }
    
    // Format time into display string
    func getTimeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds);
    }
    
    // Get proper track color based off of application state
    func getTrackColor() -> CGColor {
        if currentPomodoroInterval.isBreak {
            return color(from: ColorTheme.red.rawValue)
        } else {
            return color(from: ColorTheme.blue.rawValue)
        }
    }
    
    // HELPER - Convert Hex value to CGColor
    func color(from hexString : String, withAlpha alpha: CGFloat = 1.0) -> CGColor
    {
        if let rgbValue = UInt(hexString, radix: 16) {
            let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
            let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
            let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
            return NSColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
        } else {
            return NSColor.black.cgColor
        }
    }
}

extension TimerViewController: NSUserNotificationCenterDelegate {
    func showNotification(withTitle title: String, withBody body: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
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

// Color theme
enum ColorTheme: String {
    case red = "d46164"
    case blue = "109bde"
    case green = "2ecc71"
}
