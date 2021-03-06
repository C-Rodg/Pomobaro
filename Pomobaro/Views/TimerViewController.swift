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
    var isTimerComplete: Bool = false
    var currentSeconds: Double = 1500
    var timer = Timer()
    var isTimerRunning = false
    var resumeTapped = false
    let pomodoroInstance: PomodoroTimer = PomodoroTimer()
    var currentPomodoroInterval: PomodoroTimeInterval = PomodoroTimeInterval(timer: 1500, isBreak: false)
    
    // Animation
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var pomoIndicators: [CAShapeLayer] = []
    
    // Outlets - Main View
    @IBOutlet weak var timerView: NSView!
    @IBOutlet weak var timerLabel: NSTextField!
    @IBOutlet weak var playPauseButton: NSButton!
    @IBOutlet weak var resetIntervalButton: NSButton!
    @IBOutlet weak var resetAllButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var closeButton: NSButton!
    @IBOutlet weak var indicatorView: NSView!
    @IBOutlet weak var pomoCountLabel: NSTextField!
    
    // Outlets - Settings View
    @IBOutlet weak var settingsView: NSView!
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var workTimeInput: NSTextField!
    @IBOutlet weak var shortBreakInput: NSTextField!
    @IBOutlet weak var longBreakInput: NSTextField!
    @IBOutlet weak var settingsErrorMessage: NSTextField!
    @IBOutlet weak var restoreDefaultsButton: NSButton!
    @IBOutlet weak var pomodoroAmountInput: NSTextField!
    
    // LIFECYCLE EVENT - Initial Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the background
        createGradientBackground()
        
        // Style the buttons
        styleControlButtons()
        
        // Get inital values
        currentPomodoroInterval = pomodoroInstance.getCurrentInterval()
        currentSeconds = currentPomodoroInterval.timer
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        setupInitialTracks()
        
        // Allow Notifications
        NSUserNotificationCenter.default.delegate = self
        
        // Hide settings controls
        settingsView.isHidden = true
        
        // Style inputs
        styleSettingsInputs()
        
        // Add notification for menubar color change
        DistributedNotificationCenter.default.addObserver(self, selector: #selector(styleSettingsInputs), name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), object: nil)
    }
   
    // FUNCTIONALITY - Change status bar based off of current status
    func alterStatusBarTo(_ status: String) {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        let imageName = "taskbar_" + status
        if let currentStatusImage = NSImage(named: NSImage.Name(imageName)) {
             appDelegate.statusItem.image = currentStatusImage
            if status == "default" {
                appDelegate.statusItem.image?.isTemplate = true
            } else {
                appDelegate.statusItem.image?.isTemplate = false
            }
        } else {
            appDelegate.statusItem.image = NSImage(named: NSImage.Name("statusbar_default"))
            appDelegate.statusItem.image?.isTemplate = true
        }
    }
    
    // FUNCTIONALITY - Switch between main and settings views
    func toggleSettingsView() {
        
        if settingsView.isHidden {
            // Going to settings view
            timerView.isHidden = true
            settingsView.isHidden = false
            settingsErrorMessage.isHidden = true
            workTimeInput.doubleValue = pomodoroInstance.timeWork / 60
            shortBreakInput.doubleValue = pomodoroInstance.timeShortBreak / 60
            longBreakInput.doubleValue = pomodoroInstance.timeLongBreak / 60
            pomodoroAmountInput.integerValue = pomodoroInstance.totalPomodoros
            
            // Set default text input position
            pomodoroAmountInput.becomeFirstResponder()
            pomodoroAmountInput.currentEditor()?.selectedRange = NSRange(location: 2, length: 0)
        } else {
            // Returning home
            if validateInputIntervals() {
                handleInputIntervalChanges()
                timerView.isHidden = false
                settingsView.isHidden = true
            }
        }
    }
    
    // FUNCTIONALITY - Determine input values changed and current timer status
    func handleInputIntervalChanges() {
        let defaults = UserDefaults.standard
        let workInputDouble = workTimeInput.doubleValue * 60
        let shortInputDouble = shortBreakInput.doubleValue * 60
        let longInputDouble = longBreakInput.doubleValue * 60
        let pomoInputInt = pomodoroAmountInput.integerValue
        
        if workInputDouble == pomodoroInstance.timeWork && shortInputDouble == pomodoroInstance.timeShortBreak && longInputDouble == pomodoroInstance.timeLongBreak && pomoInputInt == pomodoroInstance.totalPomodoros {
            return
        }
        
        var currentIntervalHasChanged = false
        
        if workInputDouble != pomodoroInstance.timeWork {
            // Work time has changed
            pomodoroInstance.timeWork = workInputDouble
            defaults.set(workInputDouble, forKey: "pomoWork")
            if !currentPomodoroInterval.isBreak {
                currentIntervalHasChanged = true
            }
        }
        
        if shortInputDouble != pomodoroInstance.timeShortBreak {
            // Short break has changed
            pomodoroInstance.timeShortBreak = shortInputDouble
            defaults.set(shortInputDouble, forKey: "pomoShort")
            if currentPomodoroInterval.isBreak && !currentPomodoroInterval.isLongBreak {
                currentIntervalHasChanged = true
            }
        }
        
        if longInputDouble != pomodoroInstance.timeLongBreak {
            // Long break has changed
            pomodoroInstance.timeLongBreak = longInputDouble
            defaults.set(longInputDouble, forKey: "pomoLong")
            if currentPomodoroInterval.isBreak && currentPomodoroInterval.isLongBreak {
                currentIntervalHasChanged = true
            }
        }
        
        // Set the last key and now load from database
        if pomoInputInt != pomodoroInstance.totalPomodoros {
            defaults.set(pomoInputInt, forKey: "totalPomodoros")
        }
        
        
        if pomoInputInt != pomodoroInstance.totalPomodoros {
            
            if pomoInputInt < pomodoroInstance.currentIndex {
                // Less pomodoros, reset timer completely
                pomodoroInstance.totalPomodoros = pomoInputInt
                pomodoroInstance.generateTimeArray()
                resetButtonClicked(nil)
            } else {
                // More pomodoros, just continue
                pomodoroInstance.totalPomodoros = pomoInputInt
                pomodoroInstance.generateTimeArray()
            }
            
            if pomoInputInt > 8 {
                // Show text pomodoros
                hidePomodoroIndicators()
                pomoCountLabel.isHidden = false
                assignCountLabelValues()
            } else {
                // Create icons
                hidePomodoroIndicators()
                generatePomodoroIndicators()
                fillAndColorIndicators()
            }
        } else {
            pomodoroInstance.getIntervalsFromDatabase()
        }
        
        pomodoroInstance.generateTimeArray()
        
        if currentIntervalHasChanged {
            resetIntervalButtonClicked(nil)
        }
    }
    
    // FUNCTIONALITY - Validate values of input fields
    func validateInputIntervals() -> Bool {
        let workTime = workTimeInput.doubleValue
        let shortBreak = shortBreakInput.doubleValue
        let longBreak = longBreakInput.doubleValue
        let amountPomo = pomodoroAmountInput.integerValue
        var errorMsg = ""
        if workTime < 1.0 || longBreak < 1.0 || shortBreak < 1.0 {
            errorMsg = "All intervals must be at least 1 minute."
        } else if workTime >= 100.0 || longBreak >= 100.0 || shortBreak >= 100.0 {
            errorMsg = "Intervals must be less than 100 minutes."
        }
        
        if amountPomo < 1 {
            errorMsg = "Must have at least one pomodoro."
        } else if amountPomo >= 100 {
            errorMsg = "Must have less than 100 pomodoros."
        }
        
        // Show error
        if errorMsg != "" {
            NSSound(named: NSSound.Name("Funk"))?.play()
            settingsErrorMessage.stringValue = errorMsg
            settingsErrorMessage.isHidden = false
            return false
        }
        return true
    }
    
    // STYLE - Remove native button styles
    func styleControlButtons() {
        let btns:[NSButton] = [closeButton, playPauseButton, resetIntervalButton, resetAllButton, settingsButton, backButton]
        for btn in btns {
            btn.appearance = NSAppearance(named: .aqua)
            btn.bezelStyle = .texturedSquare
            btn.isBordered = false
            btn.wantsLayer = true
            btn.layer?.backgroundColor = NSColor.clear.cgColor
        }
        
        // Restore default button
        restoreDefaultsButton.appearance = NSAppearance(named: .aqua)
        restoreDefaultsButton.bezelStyle = .texturedSquare
        restoreDefaultsButton.isBordered = true
    }
    
    
    // ANIMATION - Setup Initial tracks
    func setupInitialTracks() -> Void {
        // Indicator view
        indicatorView.wantsLayer = true
        
        let circularPath = NSBezierPath()
        circularPath.appendArc(withCenter: .zero, radius: CGFloat(125), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        circularPath.close()
        
        // Track Layer #1
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = color(from: "e5e5e5")
        trackLayer.lineWidth = 6
        trackLayer.fillColor = NSColor.clear.cgColor
        trackLayer.position = CGPoint(x: 175, y: 165)
        
        // Add track layers to view
        timerView.wantsLayer = true
        timerView.layer?.addSublayer(trackLayer)
        
        // Setup progress
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = color(from : ColorTheme.blue.rawValue)
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = NSColor.clear.cgColor
        //shapeLayer.lineCap = kCALineCapRound
        shapeLayer.position = CGPoint(x: 175, y: 165)
        shapeLayer.transform = CATransform3DMakeRotation((CGFloat.pi / 2), 0, 0, 1)
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.fillMode = kCAFillModeForwards
        timerView.layer?.addSublayer(shapeLayer)
        
        // Create indicators
        generatePomodoroIndicators()
    }
    
    // STYLE - Create the gradient background
    func createGradientBackground() {
        let backgroundView = NSView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        let colorTop = color(from: "1e3148")
        let colorBottom = color(from: "141E30")
        let gradient  = CAGradientLayer()
        gradient.colors = [colorBottom, colorTop]
        gradient.locations = [0.1, 1.0]
        gradient.frame = backgroundView.bounds
        
        view.layer?.addSublayer(gradient)
    }
    
    // STYLE - Assign count label values
    func assignCountLabelValues() {
        pomoCountLabel.stringValue = "\(pomodoroInstance.getPomodoroCount()) of \(pomodoroInstance.totalPomodoros) pomodoros"
    }
    
    // STYLE - Generate pomodoro indicators
    func generatePomodoroIndicators() {
        pomoIndicators = []
        if pomodoroInstance.totalPomodoros > 8 {
            hidePomodoroIndicators()
            assignCountLabelValues()
            pomoCountLabel.isHidden = false
        } else {
            pomoCountLabel.isHidden = true
            // x-path slots
            let xPaths: [Int] = [26, 46, 66, 86, 106, 126, 146, 166]
            
            var startPosition = 0
            let slots = xPaths.count - 1
            let len = pomodoroInstance.totalPomodoros
            var itemsAfter = slots - len
            while startPosition < itemsAfter {
                if startPosition == itemsAfter {
                    break;
                }
                startPosition += 1
                itemsAfter = slots - len - startPosition
            }
            
            let isEven = pomodoroInstance.totalPomodoros % 2 == 0
            
            for x in startPosition...(startPosition + len - 1) {
                let circularPath = NSBezierPath()
                circularPath.appendArc(withCenter: .zero, radius: CGFloat(6), startAngle: CGFloat(0), endAngle: CGFloat(2 * Double.pi), clockwise: true)
                circularPath.close()
                let trackLayer = CAShapeLayer()
                trackLayer.path = circularPath.cgPath
                trackLayer.lineWidth = 2
                trackLayer.fillColor = NSColor.clear.cgColor
                trackLayer.strokeColor = color(from: ColorTheme.blue.rawValue, withAlpha: 0.4)
                let xPosition = isEven ? xPaths[x] : xPaths[x] + 9
                trackLayer.position = CGPoint(x: xPosition, y: 15)
                indicatorView.layer?.addSublayer(trackLayer)
                pomoIndicators.append(trackLayer)
            }
            
            
        }
    }
    
    
    // ANIMATION - Switch pomodoro indicator colors from break to no break
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
    
    // ANIMATION - color and fill already complete pomodoros
    func fillAndColorIndicators() {
        let currentCount = pomodoroInstance.getPomodoroCount()
        if currentCount == 0 {
            return
        }
        let instanceColor = currentPomodoroInterval.isBreak ? ColorTheme.red.rawValue : ColorTheme.blue.rawValue
        for i in 0...currentCount - 1 {
            if i < pomoIndicators.count {
                pomoIndicators[i].fillColor = color(from: instanceColor)
                pomoIndicators[i].strokeColor = color(from: instanceColor)
            }
        }
    }
    
    // FUNCTIONALITY - Reset Pomodoro indicators
    func resetPomodoroIndicators() {
        for pomo in pomoIndicators {
            pomo.removeAllAnimations()
            pomo.fillColor = CGColor.clear
            pomo.strokeColor = color(from: ColorTheme.blue.rawValue, withAlpha: 0.4)
        }
    }
    
    // FUNCTIONALITY - Hide Pomodoro indicators
    func hidePomodoroIndicators() {
        for pomo in pomoIndicators {
            pomo.isHidden = true
        }
        if let layer = indicatorView.layer, let sublayers = layer.sublayers {
            sublayers.forEach { $0.removeFromSuperlayer() }
        }
    }
    
    // ANIMATION - Add pulsing and fill effect
    func completeIndividualPomoIndicator(count: Int) {
        animatePomoIndicator(for: count-1, with: ColorTheme.blue.rawValue)
    }
    
    // ANIMATION - Helper animation for pomo indicators
    func animatePomoIndicator(for i: Int, with stringColor: String) {
        if pomoIndicators.count == 0 {
            return
        }
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
    
    // ANIMATION - All pomodoros are completed
    func completeAllPomoIndicitator() {
        for index in 0..<pomoIndicators.count {
            animatePomoIndicator(for: index, with: "2ecc71")
        }
    }
    
    // EVENT - Play/pause button clicked
    @IBAction func playPauseButtonClicked(_ sender: Any?) {
        if isTimerRunning == false {
            isTimerComplete = false
            runTimer()
            playPauseButton.image = NSImage(imageLiteralResourceName: "pause")
            if currentPomodoroInterval.isBreak {
                alterStatusBarTo("red")
            } else {
                alterStatusBarTo("blue")
            }
        } else {
            timer.invalidate()
            playPauseButton.image = NSImage(imageLiteralResourceName: "play")
            isTimerRunning = false
            alterStatusBarTo("default")
        }
    }
    
    // EVENT - Switch from Main View <-> Settings View
    @IBAction func handleRouteChange(_ sender: NSButton) {
        toggleSettingsView()
    }
    
    // EVENT - close the application down
    @IBAction func handleCloseApp(_ sender: NSButton) {
        NSApplication.shared.terminate(self)
    }
    
    
    // EVENT - Reset All clicked
    @IBAction func resetButtonClicked(_ sender: NSButton?) {
        isTimerComplete = false
        playPauseButton.isHidden = false
        resetIntervalButton.isHidden = false
        resetPomodoroIndicators()
        
        timer.invalidate()
        currentPomodoroInterval = pomodoroInstance.resetTimer()
        currentSeconds = currentPomodoroInterval.timer
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeColor = getTrackColor()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        assignCountLabelValues()
        playPauseButton.image = NSImage(imageLiteralResourceName: "play")
        alterStatusBarTo("default")
    }
    
    // EVENT - Reset Interval clicked
    @IBAction func resetIntervalButtonClicked(_ sender: NSButton?) {
        if isTimerComplete {
            // Change colors of intervals
            fillAndColorIndicators()
        }
        isTimerComplete = false
        timer.invalidate()
        currentPomodoroInterval  = pomodoroInstance.getCurrentInterval()
        currentSeconds = currentPomodoroInterval.timer
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeColor = getTrackColor()
        timerLabel.stringValue = getTimeString(time: TimeInterval(currentSeconds))
        isTimerRunning = false
        playPauseButton.image = NSImage(imageLiteralResourceName: "play")
        alterStatusBarTo("default")
    }
    
    // EVENT - Restore Default clicked
    @IBAction func restoreDefaults(_ sender: NSButton) {
        workTimeInput.doubleValue = 25
        shortBreakInput.doubleValue = 5
        longBreakInput.doubleValue = 15
        pomodoroAmountInput.integerValue = 4
    }
    
    // FUNCTIONALITY - Run Timer loop
    func runTimer() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
        
        isTimerRunning = true
    }
    
    // FUNCTIONALITY - Update the timer label view
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
                    if newInterval.isLongBreak {
                        title = "Long Break!"
                        let messageStart = pomodoroCount > 1 ? "\(pomodoroCount) pomodoros down." : "1 pomodoro down."
                        msg = messageStart + "  Let's take a long break."
                    } else if pomodoroCount == 1 {
                        msg = "1 pomodoro down. Let's take a short break."
                    } else {
                        msg = "\(pomodoroCount) pomodoros down. Let's take another short break."
                    }
                    if pomoCountLabel.isHidden {
                        completeIndividualPomoIndicator(count: pomodoroCount)
                    }
                }
                showNotification(withTitle: title, withBody: msg)
                assignCountLabelValues()
                changePomodoroColor(isBreak)
                if currentPomodoroInterval.isBreak {
                    alterStatusBarTo("red")
                } else {
                    alterStatusBarTo("blue")
                }
            } else {
                // Stop timer completely
                isTimerComplete = true
                timer.invalidate()
                playPauseButton.isHidden = true
                resetIntervalButton.isHidden = true
                isTimerRunning = false
                alterStatusBarTo("green")
                
                showNotification(withTitle: "Timer Complete!", withBody: "Long break is over. Time to start again?.")
                shapeLayer.strokeColor = color(from: ColorTheme.green.rawValue)
                if pomoCountLabel.isHidden {
                    completeAllPomoIndicitator()
                }
            }
        }
    }
    
    // FUNCTIONALITY - Format time into display string
    func getTimeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds);
    }
    
    // STYLE - Get proper track color based off of application state
    func getTrackColor() -> CGColor {
        if currentPomodoroInterval.isBreak {
            return color(from: ColorTheme.red.rawValue)
        } else {
            return color(from: ColorTheme.blue.rawValue)
        }
    }
    
    // STYLE - style the inputs based off of theme color
    @objc func styleSettingsInputs() {
        let color = getMenuBarColor()
        if color == "Light" {
            workTimeInput.textColor = NSColor.black
            shortBreakInput.textColor = NSColor.black
            longBreakInput.textColor = NSColor.black
            pomodoroAmountInput.textColor = NSColor.black
        } else {
            workTimeInput.textColor = NSColor.white
            shortBreakInput.textColor = NSColor.white
            longBreakInput.textColor = NSColor.white
            pomodoroAmountInput.textColor = NSColor.white
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
    
    // HELPER - detect menu bar color
    func getMenuBarColor() -> String {
        let color = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        return color
    }
}

// DELEGATION - Notification Delegate
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

// EXTENSION - Add cgPath to NSBezierPath
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
