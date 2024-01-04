//
//  PLCViewController.swift
//  HomeControl
//
//  Created by Joachim Kittelberger on 16.06.17.
//  Copyright © 2017 Joachim Kittelberger. All rights reserved.
//

import UIKit

class PLCViewController: UIViewController {

    // TODO Jet32
//        var homeConnection = Jet32NW.sharedInstance
    var homeConnection = Jet32.sharedInstance
 
    enum PLCViewControllerTag: UInt32 {
        case readSecond
        case readMinute
        case readHour
        case readHourShutterUp
        case readMinuteShutterUp
        case readHourShutterDown
        case readMinuteShutterDown
        case readHourShutterUpWeekend
        case readMinuteShutterUpWeekend
        
        case readIsAutomaticBlind
        case readIsAutomaticShutter
        case readIsAutomaticSummerMode

        case readIsSaunaOn
        
        case readCurrentStateNightDay
        case readCurrentStateWind
        case readCurrentStateLight
        
        case readUseSunsetSettings
        case readSunsetHourForToday
        case readSunsetMinuteForToday
        case readSunsetOffsetInMin
    }
    
    
    var hour: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    var timer: Timer!       // Timer for reading the PLC Time
    
    var sunsetHour: Int = 0
    var sunsetMinute: Int = 0
    
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBAction func setTimeButton(_ sender: Any) {
        writeCurrtenTimeToPLC()
    }
    
    @IBOutlet weak var hourShutterUp: UITextField!
    @IBOutlet weak var minuteShutterUp: UITextField!
    @IBOutlet weak var hourShutterDown: UITextField!
    @IBOutlet weak var minuteShutterDown: UITextField!
    @IBOutlet weak var hourShutterUpWeekend: UITextField!
    @IBOutlet weak var minuteShutterUpWeekend: UITextField!
    
    @IBOutlet weak var isBlindAutomaticSwitch: UISwitch!
    @IBOutlet weak var isShutterAutomaticSwitch: UISwitch!
    @IBOutlet weak var isShutterSommerPos: UISwitch!
    @IBOutlet weak var isSaunaOnSwitch: UISwitch!
    @IBOutlet weak var currentMode: UILabel!
    @IBOutlet weak var currentStateWind: UILabel!
    @IBOutlet weak var currentStateLight: UILabel!

    // 08.11.2021 JK: added support for sunset
    @IBOutlet weak var useSunsetSettings: UISwitch!
    @IBOutlet weak var sunsetOffsetInMin: UITextField!
    @IBOutlet weak var labelSunsetTime: UILabel!
    
    @IBAction func allShuttersUp(_ sender: Any) {
        homeConnection.setFlag(Jet32GlobalVariables.flagCmdAllAutomaticShuttersUp)
    }

    @IBAction func allShuttersDown(_ sender: Any) {
        homeConnection.setFlag(Jet32GlobalVariables.flagCmdAllAutomaticShuttersDown)
    }
    
    @IBAction func allShuttersSommerPosUp(_ sender: Any) {
        homeConnection.setFlag(Jet32GlobalVariables.flagCmdAllAutomaticShuttersUpSummerPos)
    }
    
    @IBAction func allShuttersSommerPosDown(_ sender: Any) {
        homeConnection.setFlag(Jet32GlobalVariables.flagCmdAllAutomaticShuttersDownSummerPos)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        // set the IDs of the controls TODO sollte eigentlich nur eimal gemacht werden.
        hourShutterUp.tag = Int(PLCViewControllerTag.readHourShutterUp.rawValue)
        minuteShutterUp.tag = Int(PLCViewControllerTag.readMinuteShutterUp.rawValue)
        hourShutterDown.tag = Int(PLCViewControllerTag.readHourShutterDown.rawValue)
        minuteShutterDown.tag = Int(PLCViewControllerTag.readMinuteShutterDown.rawValue)
        hourShutterUpWeekend.tag = Int(PLCViewControllerTag.readHourShutterUpWeekend.rawValue)
        minuteShutterUpWeekend.tag = Int(PLCViewControllerTag.readMinuteShutterUpWeekend.rawValue)
        
        isBlindAutomaticSwitch.tag = Int(PLCViewControllerTag.readIsAutomaticBlind.rawValue)
        isShutterAutomaticSwitch.tag = Int(PLCViewControllerTag.readIsAutomaticShutter.rawValue)
        isShutterSommerPos.tag = Int(PLCViewControllerTag.readIsAutomaticSummerMode.rawValue)
        isSaunaOnSwitch.tag = Int(PLCViewControllerTag.readIsSaunaOn.rawValue)

        useSunsetSettings.tag = Int(PLCViewControllerTag.readUseSunsetSettings.rawValue)
        sunsetOffsetInMin.tag = Int(PLCViewControllerTag.readSunsetOffsetInMin.rawValue)

        isBlindAutomaticSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        isShutterAutomaticSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        isShutterSommerPos.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        isSaunaOnSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

        useSunsetSettings.addTarget(self, action: #selector(switchChanged), for:
            UIControl.Event.valueChanged)
        
        currentMode.text = "Aktueller Modus: ???"
        currentStateWind.text = "Aktueller Windstatus: ???"
        currentStateLight.text = "Aktueller Lichtstatus: ???"
        labelSunsetTime.text = "Rolladen ab (SU): ???"



        // TODO jk: Müsste eigentlich in viewDidAppear gemacht werden. Ist das erste mal dort aber zu früh
//        readTimeFromPLC()
        // hier nochmal aufrufen, damit die Werte wirklich auch dargestellt werden.
        readTimeSettingsFromPLC()
//        readShutterSettingsFromPLC()
//        readOtherSettingsFromPLC()
//        readStatesFromPLC()
    }

 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        homeConnection.setDelegate(delegate: self)

        readTimeSettingsFromPLC()
        readShutterSettingsFromPLC()
        readOtherSettingsFromPLC()
        readStatesFromPLC()

        readTimeFromPLC()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer.invalidate()
        homeConnection.setDelegate(delegate: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func onTimer() {
        readTimeFromPLC()
        readStatesFromPLC()
   }
    
    func readTimeFromPLC() {
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regSecond, tag: UInt32(PLCViewControllerTag.readSecond.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regMinute, tag: UInt32(PLCViewControllerTag.readMinute.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regHour, tag: UInt32(PLCViewControllerTag.readHour.rawValue))
    }

    func readStatesFromPLC() {
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regCurrentStateNightDay, tag: UInt32(PLCViewControllerTag.readCurrentStateNightDay.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regCurrentStateWind, tag: UInt32(PLCViewControllerTag.readCurrentStateWind.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regCurrentStateLight, tag: UInt32(PLCViewControllerTag.readCurrentStateLight.rawValue))
    }

    
    // TODO for Test sync calls
    func readStatesFromPLCSync() {

        let currentStateNightDay = homeConnection.readIntRegSync(Jet32GlobalVariables.regCurrentStateNightDay, tag: UInt32(PLCViewControllerTag.readCurrentStateNightDay.rawValue))
        let currentStateWind = homeConnection.readIntRegSync(Jet32GlobalVariables.regCurrentStateWind, tag: UInt32(PLCViewControllerTag.readCurrentStateWind.rawValue))
        let currentStateLight = homeConnection.readIntRegSync(Jet32GlobalVariables.regCurrentStateLight, tag: UInt32(PLCViewControllerTag.readCurrentStateLight.rawValue))
        
        setModeLabelText(mode: Int(currentStateNightDay))
        setStateWindLabelText(state: Int(currentStateWind))
        setStateLightLabelText(state: Int(currentStateLight))
    
    }
    

    func readTimeSettingsFromPLC() {
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regUpTimeHour, tag: UInt32(PLCViewControllerTag.readHourShutterUp.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regUpTimeMinute, tag: UInt32(PLCViewControllerTag.readMinuteShutterUp.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regDownTimeHour, tag: UInt32(PLCViewControllerTag.readHourShutterDown.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regDownTimeMinute, tag: UInt32(PLCViewControllerTag.readMinuteShutterDown.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regUpTimeHourWeekend, tag: UInt32(PLCViewControllerTag.readHourShutterUpWeekend.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regUpTimeMinuteWeekend, tag: UInt32(PLCViewControllerTag.readMinuteShutterUpWeekend.rawValue))
    }
    
    func readShutterSettingsFromPLC() {
        let _ = homeConnection.readFlagOld(Jet32GlobalVariables.flagIsAutomaticBlind, tag: UInt32(PLCViewControllerTag.readIsAutomaticBlind.rawValue))
        let _ = homeConnection.readFlagOld(Jet32GlobalVariables.flagIsAutomaticShutter, tag: UInt32(PLCViewControllerTag.readIsAutomaticShutter.rawValue))
        let _ = homeConnection.readFlagOld(Jet32GlobalVariables.flagIsAutomaticSummerMode, tag: UInt32(PLCViewControllerTag.readIsAutomaticSummerMode.rawValue))
    }
    
    func readOtherSettingsFromPLC() {
        let _ = homeConnection.readFlagOld(Jet32GlobalVariables.flagIsSaunaOn, tag: UInt32(PLCViewControllerTag.readIsSaunaOn.rawValue))

        let _ = homeConnection.readFlagOld(Jet32GlobalVariables.flagUseSunsetSettings, tag: UInt32(PLCViewControllerTag.readUseSunsetSettings.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regSunsetOffsetInMin, tag: UInt32(PLCViewControllerTag.readSunsetOffsetInMin.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regSunsetHourForToday, tag: UInt32(PLCViewControllerTag.readSunsetHourForToday.rawValue))
        let _ = homeConnection.readIntReg(Jet32GlobalVariables.regSunsetMinuteForToday, tag: UInt32(PLCViewControllerTag.readSunsetMinuteForToday.rawValue))
    }
    
    

    
    func writeCurrtenTimeToPLC() {
        let date = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
    
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date) - 2000

        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regYear, to: year)
        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regMonth, to: month)
        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regDay, to: day)
        
        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regHour, to: hour)
        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regMinute, to: minutes)
        let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regSecond, to: seconds)
    }
    
    
    func setTimeLabelText() {
        let strSeconds = String.init(format: "%02d", seconds)
        let strMinutes = String.init(format: "%02d", minutes)
        let strHour = String.init(format: "%02d", hour)
        
        timeLabel.text = "\(strHour):\(strMinutes):\(strSeconds)"
    }
    

    func setModeLabelText(mode: Int) {

        var strState = ""
        switch (mode) {
        case 0:
            strState = "Tag"
        case 1:
            strState = "Nacht"
        default:
            strState = "Unbekannt"
        }
        
        let strLabel = String.init(format: "Aktueller Modus: %02d - %@", mode, strState)
        currentMode.text = strLabel
    }
    

    func setStateWindLabelText(state: Int) {

        var strState = ""
        switch (state) {
        case 0:
            strState = "Wind erkannt"
        case 1:
            strState = "zu viel Wind"
        case 2:
            strState = "kein Wind erkannt"
        case 3:
            strState = "kein Wind"
        default:
            strState = "Unbekannt"
        }
        
        let strLabel = String.init(format: "Aktueller Windstatus: %02d - %@", state, strState)
        currentStateWind.text = strLabel
    }


    func setStateLightLabelText(state: Int) {

        var strState = ""
        switch (state) {
        case 0:
            strState = "Hell erkannt"
        case 1:
            strState = "Hell"
        case 2:
            strState = "Dunkel erkannt"
        case 3:
            strState = "Dunkel"
        default:
            strState = "Unbekannt"
        }
        
        let strLabel = String.init(format: "Aktueller Lichtstatus: %02d - %@", state, strState)
        currentStateLight.text = strLabel
    }
    
    
    
    func setSunsetLabelText() {
        let offset = Int(sunsetOffsetInMin.text!)!
        
        let shutterDownHour = sunsetHour + ((sunsetMinute + offset) / 60)
        let shutterDownMinute = Int((sunsetMinute + offset) % 60)
        
        let strMinutes = String.init(format: "%02d", shutterDownMinute)
        let strHour = String.init(format: "%02d", shutterDownHour)
       
        labelSunsetTime.text = "Rolladen ab (SU): \(strHour):\(strMinutes)"
    }
    
    
    
    @objc func switchChanged(mySwitch: UISwitch) {
        
        let isOn = mySwitch.isOn
        
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(mySwitch.tag)) {
            
            switch (plcTag) {
            case .readIsAutomaticBlind:
                isOn ? homeConnection.setFlag(Jet32GlobalVariables.flagIsAutomaticBlind) : homeConnection.resetFlag(Jet32GlobalVariables.flagIsAutomaticBlind)
                
            case .readIsAutomaticShutter:
                isShutterSommerPos.isEnabled = isOn
                isOn ? homeConnection.setFlag(Jet32GlobalVariables.flagIsAutomaticShutter) : homeConnection.resetFlag(Jet32GlobalVariables.flagIsAutomaticShutter)
                
            case .readIsAutomaticSummerMode:
                isOn ? homeConnection.setFlag(Jet32GlobalVariables.flagIsAutomaticSummerMode) : homeConnection.resetFlag(Jet32GlobalVariables.flagIsAutomaticSummerMode)

            case .readIsSaunaOn:
                isOn ? homeConnection.setFlag(Jet32GlobalVariables.flagIsSaunaOn) : homeConnection.resetFlag(Jet32GlobalVariables.flagIsSaunaOn)

            case .readUseSunsetSettings:
                isOn ? homeConnection.setFlag(Jet32GlobalVariables.flagUseSunsetSettings) : homeConnection.resetFlag(Jet32GlobalVariables.flagUseSunsetSettings)

            default:
                print("Error: switchChanged no case for tag \(mySwitch.tag)")
            }
        }
        
        print("switchChanged tag: \(mySwitch.tag)")
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



extension PLCViewController: Jet32Delegate {
    
    func didReceiveReadRegister(value: UInt, tag: UInt) {
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(tag)) {
            switch (plcTag) {
            case .readSecond:
                seconds = Int(value)
                setTimeLabelText()
            case .readMinute:
                minutes = Int(value)
                setTimeLabelText()
            case .readHour:
                hour = Int(value)
                setTimeLabelText()
            
            
            case .readHourShutterUp:
                hourShutterUp.text = String.init(format: "%02d", value)

            case .readMinuteShutterUp:
                minuteShutterUp.text = String.init(format: "%02d", value)

            case .readHourShutterDown:
                hourShutterDown.text = String.init(format: "%02d", value)

            case .readMinuteShutterDown:
                minuteShutterDown.text = String.init(format: "%02d", value)

            case .readHourShutterUpWeekend:
                hourShutterUpWeekend.text = String.init(format: "%02d", value)

            case .readMinuteShutterUpWeekend:
                minuteShutterUpWeekend.text = String.init(format: "%02d", value)


            case .readCurrentStateNightDay:
                setModeLabelText(mode: Int(value))
                
            case .readCurrentStateWind:
                setStateWindLabelText(state: Int(value))
                
            case .readCurrentStateLight:
                setStateLightLabelText(state: Int(value))
 
                
            case .readSunsetOffsetInMin:
                sunsetOffsetInMin.text = String.init(format: "%02d", value)
                setSunsetLabelText()
            
            case .readSunsetHourForToday:
                sunsetHour = Int(value)
                setSunsetLabelText()

            case .readSunsetMinuteForToday:
                sunsetMinute = Int(value)
                setSunsetLabelText()

                
            default:
                print("Error: didReceiveReadRegister no case for tag \(tag)")
                
            }
//            print("didReceiveReadRegister \(value) \(tag)")
        }
    }

    
    func didReceiveReadFlag(value: Bool, tag: UInt) {
        
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(tag)) {
            
            switch (plcTag) {
                
            case .readIsAutomaticBlind:
                isBlindAutomaticSwitch.setOn(value, animated: false)
                
            case .readIsAutomaticShutter:
                isShutterAutomaticSwitch.setOn(value, animated: false)
                isShutterSommerPos.isEnabled = value
                
            case .readIsAutomaticSummerMode:
                isShutterSommerPos.setOn(value, animated: false)

            case .readIsSaunaOn:
                isSaunaOnSwitch.setOn(value, animated: false)

            case .readUseSunsetSettings:
                useSunsetSettings.setOn(value, animated: false)

            default:
                print("Error: didReceiveReadFlag no case for tag \(tag)")
                
            }
//            print("didReceiveReadFlag \(value) \(tag)")
        }
        
    }
    
}


extension PLCViewController: UITextFieldDelegate {
    
    // MARK: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    func textFieldDidEndEditing(_ textField: UITextField) {
    
        if let plcTag = PLCViewControllerTag(rawValue: UInt32(textField.tag)) {
            switch (plcTag) {
            case .readHourShutterUp:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regUpTimeHour, to: Int(textField.text!)!)
            case .readMinuteShutterUp:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regUpTimeMinute, to: Int(textField.text!)!)
            case .readHourShutterDown:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regDownTimeHour, to: Int(textField.text!)!)
            case .readMinuteShutterDown:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regDownTimeMinute, to: Int(textField.text!)!)
            case .readHourShutterUpWeekend:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regUpTimeHourWeekend, to: Int(textField.text!)!)
            case .readMinuteShutterUpWeekend:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regUpTimeMinuteWeekend, to: Int(textField.text!)!)
            case .readSunsetOffsetInMin:
                let _ = homeConnection.writeIntRegister(Jet32GlobalVariables.regSunsetOffsetInMin, to: Int(textField.text!)!)
                // read new values for shutters down
                let _ = homeConnection.readIntReg(Jet32GlobalVariables.regSunsetOffsetInMin, tag: UInt32(PLCViewControllerTag.readSunsetOffsetInMin.rawValue))
            default:
                print("Error: textFieldDidEndEditing no case for tag \(textField.tag)")
                
            }
        }

        print("textFieldDidEndEditing tag: \(textField.tag)")
    }
    
    
}








extension PLCViewController: PlcDataAccessibleDelegate {
    func didRedeiveReadIntRegister(_ number: UInt, with value: Int, tag: UInt) {
        print("didRedeiveReadIntRegister(tag: \(tag)): \(number): \(value)")
        
        
        
        didReceiveReadRegister(value: UInt(value), tag: tag)
        
        
        
    }
    func didRedeiveWriteIntRegister(_ number: UInt, tag: UInt) {
        
    }
    
    func didRedeiveReadFlag(_ number: UInt, with value: Bool, tag: UInt) {
        print("didReceiveReadFlag(tag: \(tag)): \(number): \(value)")
        didReceiveReadFlag(value: value, tag: tag)
        
    }
    func didRedeiveSetFlag(_ number: UInt, tag: UInt) {
        
    }
    func didRedeiveClearFlag(_ number: UInt, tag: UInt) {
        
    }
    
    func didRedeiveReadOutput(_ number: UInt, with value: Bool, tag: UInt) {
        
    }
    func didRedeiveSetOutput(_ number: UInt, tag: UInt) {
        
    }
    func didRedeiveClearOutput(_ number: UInt, tag: UInt) {
        
    }

}

