//
//  SettingsViewController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 3/31/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import UIKit
import Foundation

class SettingsViewController: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var externalLabel: UILabel!
    @IBOutlet weak var voicePicker: UIPickerView!
    @IBOutlet weak var testNoteLabel: UILabel!
    
    /* Test note stuff */
    @IBOutlet weak var testNote: Note!
    
    /* objects in filter overlay */
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var lpLabel: UILabel!
    @IBOutlet weak var lpSwitch: UISwitch!
    @IBOutlet weak var hpSwitch: UISwitch!
    @IBOutlet weak var cutoffLabel: UILabel!
    @IBOutlet weak var cutoffLabel2: UILabel!
    @IBOutlet weak var resonanceLabel: UILabel!
    @IBOutlet weak var bpLabel: UILabel!
    @IBOutlet weak var bpSwitch: UISwitch!
    
    /* objects in fx overlay */
    @IBOutlet weak var fxLabel: UILabel!
    @IBOutlet weak var echoSlider: UISlider!
    @IBOutlet weak var reverbSlider: UISlider!
    @IBOutlet weak var tremoloSlider: UISlider!
    @IBOutlet weak var echoLabel: UILabel!
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var tremoloLabel: UILabel!
    @IBOutlet weak var delaySlider: UISlider!
    @IBOutlet weak var delayLabel: UILabel!
    
    /* objects in pitch overlay */
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var octaveLabel: UILabel!
    @IBOutlet weak var semitoneLabel: UILabel!
    @IBOutlet weak var fineLabel: UILabel!
    
    var slider_octave:BWCircularSlider?
    var slider_semitone:BWCircularSlider?
    var slider_fine:BWCircularSlider?
    var slider_cutoff:BWCircularSlider?
    var slider_resonance:BWCircularSlider?
    
    @IBOutlet weak var presetButton1: UIButton!
    @IBOutlet weak var presetButton2: UIButton!
    @IBOutlet weak var presetButton3: UIButton!
    @IBOutlet weak var presetButton4: UIButton!
    
    
    var info = soundInfo()
    
    let soundKey = "soundInfo"
    
    var externalOn = true

    var pickerData = [
        ["Banjo", "Organ", "Grand Piano", "Electric Piano", "Flute", "Muted Trombone", "Flugelhorn", "Harpsichord", "Beautiful Pad", "Analog Synth"]
    ]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"app_background.jpg")!)
    
        goBackButton.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        goBackButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        
        
        presetButton1.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
         presetButton2.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
         presetButton3.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
         presetButton4.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        
        testNoteLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        pitchLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        filterLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        externalLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        fxLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
        var attr = NSDictionary(object: UIFont(name: "Helvetica-BoldOblique", size: 16.0)!, forKey: NSFontAttributeName)
        //externalSwitch.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
        
        hpLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        lpLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        lpSwitch.setOn(false, animated: false)
        hpSwitch.setOn(false, animated: false)
        bpLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        bpSwitch.setOn(false, animated: false)

        echoLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        reverbLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        delayLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)

        tremoloLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        octaveLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        semitoneLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        fineLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        cutoffLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        cutoffLabel2.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        resonanceLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
    
        info.sound = "piano_1"
        
        testNote.initialize("C4", value: 60, tColor: UIColor.blackColor(), bColor: UIColor.cyanColor())
        testNote.layer.borderColor = (UIColor.blackColor()).CGColor
        
        
        reverbSlider.minimumValue = 60
        reverbSlider.maximumValue = 100
        tremoloSlider.minimumValue = 0
        tremoloSlider.maximumValue = 127
        echoSlider.minimumValue = 0
        echoSlider.maximumValue = 127
        delaySlider.minimumValue = 0
        delaySlider.maximumValue = 80
        
        reverbSlider.value = 60
        tremoloSlider.value = 0
        echoSlider.value = 0
        delaySlider.value = 0
        
        slider_cutoff!.moveHandleTo(360)
        slider_resonance!.moveHandleTo(360)
        slider_cutoff!.updateTextField("")
        slider_resonance!.updateTextField("")

        
        initialize(voicePicker)


    }
    
    
    // picker view stuff
    func initialize(seqPicker: UIPickerView)
    {
        self.voicePicker = seqPicker
        self.voicePicker!.delegate = self
        self.voicePicker!.dataSource = self
        self.voicePicker!.selectRow(2, inComponent: 0, animated: true)
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerData[component][row], attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        return attributedString
    }
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[component][row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica-BoldOblique", size: 30.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
            case 0 : info.sound = "banjo_1"
            case 1 : info.sound = "church_organ"
            case 2 : info.sound = "piano_1"
            case 3 : info.sound = "ElPiano1"
            case 4 : info.sound = "enigma_flute"
            case 5 : info.sound = "muted_trombone"
            case 6 : info.sound = "flugelhorn"
            case 7 : info.sound = "Johansson_BeautifulPad"
            case 8 : info.sound = "rtanpad1"
        default : info.sound = "piano_1"
        }
    }
    
    @IBAction func sendSoundInfo(sender:AnyObject)  {
        NSNotificationCenter.defaultCenter().postNotificationName(soundKey, object: nil, userInfo: ["sound":info.sound, "tremolo":info.tremolo, "reverb":info.reverb, "chorus":info.chorus, "delay":info.delay, "filterFreq": info.filterFreq, "filterQ": info.filterQ, "filterType": info.filterType, "filterOn": info.filterOn, "octave": info.octave, "semitone": info.semitone, "fine": info.fine, "playNote": false, "note": testNote])
    }
    
    @IBAction func playTestNote(sender: Note) {
        NSLog("Reverb value: \(info.reverb)")
        NSNotificationCenter.defaultCenter().postNotificationName(soundKey, object: nil, userInfo: ["sound":info.sound, "tremolo":info.tremolo, "reverb":info.reverb, "chorus":info.chorus, "delay":info.delay, "filterFreq": info.filterFreq, "filterQ": info.filterQ, "filterType": info.filterType, "filterOn": info.filterOn, "octave": info.octave, "semitone": info.semitone, "fine": info.fine, "playNote": true, "note": testNote])
    }
    
    @IBAction func filterSwitchActivated(sender: UISwitch) {
        if (sender == lpSwitch && lpSwitch.on) {
            hpSwitch.setOn(false, animated: true)
            bpSwitch.setOn(false, animated: true)
            info.filterType = "lowpass"
            info.filterOn = 1
        } else if (sender == hpSwitch && hpSwitch.on) {
            lpSwitch.setOn(false, animated: true)
            bpSwitch.setOn(false, animated: true)
            info.filterType = "highpass"
            info.filterOn = 1
        } else if (sender == bpSwitch && bpSwitch.on) {
            lpSwitch.setOn(false, animated: true)
            hpSwitch.setOn(false, animated: true)
            info.filterType = "bandpass"
            info.filterOn = 1
        } else {
            info.filterOn = 0
        }
    }
    
    
    // START: Circular Slider Stuff //
    
    #if TARGET_INTERFACE_BUILDER
    override func willMoveToSuperview(newSuperview: UIView?) {
    
    let slider:BWCircularSlider = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:self.endColor, frame: self.bounds)
    self.addSubview(slider)
    
    }
    
    #else
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Build the sliders
        self.slider_octave = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 100.0, y: 370.0, width: 100.0, height: 100.0))
        self.slider_semitone = BWCircularSlider(startColor:UIColor.cyanColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 235.0, y: 370.0, width: 100.0, height: 100.0))
        self.slider_fine = BWCircularSlider(startColor:UIColor.redColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 370.0, y: 370.0, width: 100.0, height: 100.0))
        
        self.slider_cutoff = BWCircularSlider(startColor:UIColor.greenColor(), endColor:UIColor.cyanColor(), frame: CGRect(x: 283.0, y: 570.0, width: 100.0, height: 100.0))
        self.slider_resonance = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:UIColor.redColor(), frame: CGRect(x: 415.0, y: 570.0, width: 100.0, height: 100.0))


        // Attach an Action and a Target to the slider
        slider_octave!.addTarget(self, action: "octaveChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_semitone!.addTarget(self, action: "semitoneChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_fine!.addTarget(self, action: "fineChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        slider_octave!.moveHandleTo(180)
        slider_octave!.updateTextField("0")
        slider_semitone!.moveHandleTo(180)
        slider_semitone!.updateTextField("0")
        slider_fine!.moveHandleTo(180)
        slider_fine!.updateTextField("0")
        
        slider_cutoff!.addTarget(self, action: "cutoffChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_resonance!.addTarget(self, action: "resonanceChanged:", forControlEvents: UIControlEvents.ValueChanged)

        
        // Add the slider as subview of this view
        self.view.addSubview(slider_octave!)
        self.view.addSubview(slider_semitone!)
        self.view.addSubview(slider_fine!)
        self.view.addSubview(slider_cutoff!)
        self.view.addSubview(slider_resonance!)

        
    }
    #endif
    
    func octaveChanged(slider:BWCircularSlider){
        slider.moveHandleTo((slider.angle / 72) * 72 + 36)
        let options = ["-2", "-1", "0", "1", "2"]
        slider.updateTextField(options[slider.angle / 72])
        info.octave = slider.angle / 72 - 2
    }
    func semitoneChanged(slider:BWCircularSlider){
        var newAngle = (slider.angle / 14) * 14 + 12
        if newAngle > 348 {
            newAngle = 348
        }
        slider.moveHandleTo(Int(newAngle))
        let options = ["-12", "-11", "-10", "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        slider.updateTextField(options[slider.angle / 14])
        info.semitone = slider.angle / 14 - 12
    }
    func fineChanged(slider:BWCircularSlider){
        
        info.fine = scaleSlider(slider.angle, min: 0, max: 200)
        var textField = "\(info.fine - 100)"
        //if (info.fine > 100) {
        //    textField = "+" + textField
        //}
        slider.updateTextField(textField)
    }

    func cutoffChanged(slider:BWCircularSlider){
        slider_cutoff!.updateTextField("")
        info.filterFreq = scaleSlider(slider.angle, min: 0, max: 5000)
    }
    
    func resonanceChanged(slider:BWCircularSlider){
        slider_resonance!.updateTextField("")
        info.filterQ = scaleSlider(slider.angle, min: 0, max: 20)
    }
    
    func scaleSlider (value : Int!, min: Int!, max: Int!) -> Int!  {
        
        return ((value*max)/360 + min)
    }

    // END: Circluar Slider //
    
    
    @IBAction func reverbChanged(sender: UISlider) {
        info.reverb = sender.value
    }
    @IBAction func tremoloChanged(sender: UISlider) {
        info.tremolo = sender.value
    }
    @IBAction func chorusChanged(sender: UISlider) {
        info.chorus = sender.value
    }
    @IBAction func delayChanged(sender: UISlider) {
        info.delay = sender.value
    }
    
    @IBAction func presetButton1_Pressed(sender: UIButton) {
        reverbSlider.value = 60
        info.reverb = 60
        delaySlider.value = 0
        info.delay = 0
        tremoloSlider.value = 0
        info.tremolo = 0
        echoSlider.value = 0
        info.chorus = 0
        slider_cutoff!.moveHandleTo(360)
        info.filterFreq = scaleSlider(slider_cutoff!.angle, min: 0, max: 5000)
        slider_resonance!.moveHandleTo(360)
        info.filterQ = scaleSlider(slider_resonance!.angle, min: 0, max: 20)
        lpSwitch.setOn(false, animated: true)
        hpSwitch.setOn(false, animated: true)
        bpSwitch.setOn(false, animated: true)
        info.filterType = "lowpass"
        info.filterOn = 0
        self.voicePicker!.selectRow(2, inComponent: 0, animated: true)
        info.sound = "piano_1"
        info.semitone = 0
        info.octave = 0
        info.fine = 0
        slider_semitone!.moveHandleTo(180)
        slider_octave!.moveHandleTo(180)
        slider_fine!.moveHandleTo(180)
        slider_semitone!.updateTextField("0")
        slider_octave!.updateTextField("0")
        slider_fine!.updateTextField("0")
        slider_cutoff!.updateTextField("")
        slider_resonance!.updateTextField("")
        sendSoundInfo(testNote)
    }
    
    @IBAction func presetButton2_Pressed(sender: UIButton) {
        reverbSlider.value = 80
        info.reverb = 80
        delaySlider.value = 20
        info.delay = 20
        tremoloSlider.value = 40
        info.tremolo = 40
        echoSlider.value = 100
        info.chorus = 100
        slider_cutoff!.moveHandleTo(200)
        info.filterFreq = scaleSlider(slider_cutoff!.angle, min: 0, max: 5000)
        slider_resonance!.moveHandleTo(200)
        info.filterQ = scaleSlider(slider_resonance!.angle, min: 0, max: 20)
        lpSwitch.setOn(true, animated: true)
        hpSwitch.setOn(false, animated: true)
        bpSwitch.setOn(false, animated: true)
        info.filterType = "lowpass"
        info.filterOn = 1
        self.voicePicker!.selectRow(5, inComponent: 0, animated: true)
        info.sound = "muted_trombone"
        info.semitone = 0
        info.octave = 0
        info.fine = 0
        slider_semitone!.moveHandleTo(180)
        slider_octave!.moveHandleTo(180)
        slider_fine!.moveHandleTo(180)
        slider_semitone!.updateTextField("0")
        slider_octave!.updateTextField("0")
        slider_fine!.updateTextField("0")
        slider_cutoff!.updateTextField("")
        slider_resonance!.updateTextField("")
        sendSoundInfo(testNote)
    }
    
    @IBAction func presetButton3_Pressed(sender: UIButton) {
        reverbSlider.value = 90
        info.reverb = 90
        delaySlider.value = 50
        info.delay = 50
        tremoloSlider.value = 0
        info.tremolo = 0
        echoSlider.value = 120
        info.chorus = 120
        slider_cutoff!.moveHandleTo(75)
        info.filterFreq = scaleSlider(slider_cutoff!.angle, min: 0, max: 5000)
        slider_resonance!.moveHandleTo(100)
        info.filterQ = scaleSlider(slider_resonance!.angle, min: 0, max: 20)
        lpSwitch.setOn(false, animated: true)
        hpSwitch.setOn(true, animated: true)
        bpSwitch.setOn(false, animated: true)
        info.filterType = "highpass"
        info.filterOn = 1
        self.voicePicker!.selectRow(4, inComponent: 0, animated: true)
        info.sound = "enigma_flute"
        info.semitone = 0
        info.octave = 0
        info.fine = 0
        slider_semitone!.moveHandleTo(180)
        slider_octave!.moveHandleTo(180)
        slider_fine!.moveHandleTo(180)
        slider_semitone!.updateTextField("0")
        slider_octave!.updateTextField("0")
        slider_fine!.updateTextField("0")
        slider_cutoff!.updateTextField("")
        slider_resonance!.updateTextField("")
        sendSoundInfo(testNote)
    }
    
    @IBAction func presetButton4_Pressed(sender: UIButton) {
        reverbSlider.value = 65
        info.reverb = 65
        delaySlider.value = 25
        info.delay = 25
        tremoloSlider.value = 60
        info.tremolo = 60
        echoSlider.value = 60
        info.chorus = 60
        slider_cutoff!.moveHandleTo(30)
        info.filterFreq = scaleSlider(slider_cutoff!.angle, min: 0, max: 5000)
        slider_resonance!.moveHandleTo(320)
        info.filterQ = scaleSlider(slider_resonance!.angle, min: 0, max: 20)
        lpSwitch.setOn(true, animated: true)
        hpSwitch.setOn(false, animated: true)
        bpSwitch.setOn(false, animated: true)
        info.filterType = "lowpass"
        info.filterOn = 1
        self.voicePicker!.selectRow(6, inComponent: 0, animated: true)
        info.sound = "flugelhorn"
        info.semitone = 0
        info.octave = 0
        info.fine = 0
        slider_semitone!.moveHandleTo(180)
        slider_octave!.moveHandleTo(180)
        slider_fine!.moveHandleTo(180)
        slider_semitone!.updateTextField("0")
        slider_octave!.updateTextField("0")
        slider_fine!.updateTextField("0")
        slider_cutoff!.updateTextField("")
        slider_resonance!.updateTextField("")
        sendSoundInfo(testNote)
    }
    
    
}
