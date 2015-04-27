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
    //@IBOutlet weak var externalSwitch: UISegmentedControl!
    
   /* /* overlays for settings page */
    @IBOutlet weak var adsrOverlay: UIView!
    @IBOutlet weak var voiceOverlay: UIView!
    @IBOutlet weak var fxOverlay: UIView!
    @IBOutlet weak var filterOverlay: UIView! */
    
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
    
    /* objects in adsr overlay */
    @IBOutlet weak var adsrLabel: UILabel!
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var decayLabel: UILabel!
    @IBOutlet weak var sustainLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    
    var info = soundInfo()
    
    let soundKey = "soundInfo"
    
    var externalOn = true

    var pickerData = [
        ["Banjo", "Organ", "Grand Piano", "Electric Piano", "Flute", "Muted Trombone", "Les Paul", "Flugelhorn"]
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
        
        adsrLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
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
        attackLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        sustainLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        decayLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        releaseLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        cutoffLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        cutoffLabel2.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
        resonanceLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 15)
    
        info.sound = "piano_1"
        
        testNote.initialize("C4", value: 72, tColor: UIColor.blackColor(), bColor: UIColor.cyanColor())
        testNote.layer.borderColor = (UIColor.blackColor()).CGColor
        
        
        reverbSlider.minimumValue = 50
        reverbSlider.maximumValue = 100
        tremoloSlider.minimumValue = 0
        tremoloSlider.maximumValue = 127
        echoSlider.minimumValue = 0
        echoSlider.maximumValue = 127
        delaySlider.minimumValue = 0
        delaySlider.maximumValue = 127
        
        /*
        adsrOverlay.alpha = 0.5
        filterOverlay.alpha = 0.5
        voiceOverlay.alpha = 0.5
        fxOverlay.alpha = 0.5

        adsrOverlay.hidden = true
        filterOverlay.hidden = true
        fxOverlay.hidden = true
        voiceOverlay.hidden = true
        */
        
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
    
  /*  @IBAction func onPressed(sender: AnyObject) {
        externalOn = !externalOn
        if (externalOn) {
            /*
            adsrOverlay.hidden = true
            filterOverlay.hidden = true
            fxOverlay.hidden = true
            voiceOverlay.hidden = true
*/

        } else {
            /*
            adsrOverlay.hidden = false
            filterOverlay.hidden = false
            fxOverlay.hidden = false
            voiceOverlay.hidden = false
*/

        }

    }*/
    
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
            case 6 : info.sound = "LesPaul"
            case 7 : info.sound = "flugelhorn"
        default : info.sound = "piano_1"
        }
        //sendSoundInfo()
    }
    
    @IBAction func sendSoundInfo(sender:AnyObject)  {
        NSNotificationCenter.defaultCenter().postNotificationName(soundKey, object: nil, userInfo: ["sound":info.sound, "tremolo":info.tremolo, "reverb":info.reverb, "chorus":info.chorus, "delay":info.delay, "filterFreq": info.filterFreq, "filterQ": info.filterQ, "playNote": false, "note": testNote])
    }
    
    @IBAction func playTestNote(sender: Note) {
        NSNotificationCenter.defaultCenter().postNotificationName(soundKey, object: nil, userInfo: ["sound":info.sound, "tremolo":info.tremolo, "reverb":info.reverb, "chorus":info.chorus, "delay":info.delay, "filterFreq": info.filterFreq, "filterQ": info.filterQ, "playNote": true, "note": testNote])
    }
    
    @IBAction func filterSwitchActivated(sender: UISwitch) {
        if (sender == lpSwitch && lpSwitch.on) {
            hpSwitch.setOn(false, animated: true)
            bpSwitch.setOn(false, animated: true)
        } else if (sender == hpSwitch && hpSwitch.on) {
            lpSwitch.setOn(false, animated: true)
            bpSwitch.setOn(false, animated: true)
        } else if (sender == bpSwitch && bpSwitch.on) {
            lpSwitch.setOn(false, animated: true)
            hpSwitch.setOn(false, animated: true)
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
        let slider_attack:BWCircularSlider = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 60.0, y: 370.0, width: 100.0, height: 100.0))
        let slider_decay:BWCircularSlider = BWCircularSlider(startColor:UIColor.cyanColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 180.0, y: 370.0, width: 100.0, height: 100.0))
        let slider_sustain:BWCircularSlider = BWCircularSlider(startColor:UIColor.redColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 295.0, y: 370.0, width: 100.0, height: 100.0))
        let slider_release:BWCircularSlider = BWCircularSlider(startColor:UIColor.purpleColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 415.0, y: 370.0, width: 100.0, height: 100.0))
        
        let slider_cutoff:BWCircularSlider = BWCircularSlider(startColor:UIColor.greenColor(), endColor:UIColor.cyanColor(), frame: CGRect(x: 283.0, y: 570.0, width: 100.0, height: 100.0))
        let slider_resonance:BWCircularSlider = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:UIColor.redColor(), frame: CGRect(x: 415.0, y: 570.0, width: 100.0, height: 100.0))


        // Attach an Action and a Target to the slider
        slider_attack.addTarget(self, action: "attackChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_decay.addTarget(self, action: "decayChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_sustain.addTarget(self, action: "sustainChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_release.addTarget(self, action: "releaseChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        slider_cutoff.addTarget(self, action: "cutoffChanged:", forControlEvents: UIControlEvents.ValueChanged)
        slider_resonance.addTarget(self, action: "resonanceChanged:", forControlEvents: UIControlEvents.ValueChanged)

        
        // Add the slider as subview of this view
        self.view.addSubview(slider_attack)
        self.view.addSubview(slider_decay)
        self.view.addSubview(slider_sustain)
        self.view.addSubview(slider_release)
        self.view.addSubview(slider_cutoff)
        self.view.addSubview(slider_resonance)
        
        //self.view.bringSubviewToFront(adsrOverlay)
        //self.view.bringSubviewToFront(filterOverlay)
        
    }
    #endif
    
    func attackChanged(slider:BWCircularSlider){
        println("Attack value changed to \(slider.angle)")
    }
    func decayChanged(slider:BWCircularSlider){
        println("Decay value changed to \(slider.angle)")
    }
    func sustainChanged(slider:BWCircularSlider){
        println("Sustain value changed to \(slider.angle)")
    }
    func releaseChanged(slider:BWCircularSlider){
        println("Sustain value changed to \(slider.angle)")
    }

    func cutoffChanged(slider:BWCircularSlider){
        info.filterFreq = scaleSlider(slider.angle)
    }
    
    func resonanceChanged(slider:BWCircularSlider){
        info.filterQ = scaleSlider(slider.angle)
    }
    
    func scaleSlider (value : Int!) -> Int!  {
        return ((value*127)/360)
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
}
