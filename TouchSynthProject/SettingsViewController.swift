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
    @IBOutlet weak var adsrLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var externalLabel: UILabel!
    @IBOutlet weak var fxLabel: UILabel!
    @IBOutlet weak var voicePicker: UIPickerView!
    @IBOutlet weak var externalSwitch: UISegmentedControl!
    
    @IBOutlet weak var adsrOverlay: UIView!
    @IBOutlet weak var voiceOverlay: UIView!
    @IBOutlet weak var fxOverlay: UIView!
    @IBOutlet weak var filterOverlay: UIView!
    
    @IBOutlet weak var hpLabel: UILabel!
    @IBOutlet weak var lpLabel: UILabel!
    @IBOutlet weak var lpSwitch: UISwitch!
    @IBOutlet weak var hpSwitch: UISwitch!
    
    @IBOutlet weak var echoSlider: UISlider!
    @IBOutlet weak var reverbSlider: UISlider!
    @IBOutlet weak var tremoloSlider: UISlider!
    @IBOutlet weak var echoLabel: UILabel!
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var tremoloLabel: UILabel!
    
    var externalOn = true

    var pickerData = [
        ["Saxophone", "Oboe", "Grand Piano", "Polysynth", "Clarinet"]
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
        externalSwitch.setTitleTextAttributes(attr, forState: .Normal)
        
        hpLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        lpLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        lpSwitch.setOn(false, animated: false)
        hpSwitch.setOn(false, animated: false)
        echoLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        reverbLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        tremoloLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
    
        
        adsrOverlay.alpha = 0.5
        filterOverlay.alpha = 0.5
        voiceOverlay.alpha = 0.5
        fxOverlay.alpha = 0.5

        echoSlider.thumbTintColor = UIColor.purpleColor()
        initialize(voicePicker)


    }
    
    
    // picker view stuff
    func initialize(seqPicker: UIPickerView)
    {
        self.voicePicker = seqPicker
        self.voicePicker!.delegate = self
        self.voicePicker!.dataSource = self
        self.voicePicker!.selectRow(1, inComponent: 0, animated: true)
        
    }
    
    @IBAction func onPressed(sender: AnyObject) {
        externalOn = !externalOn
        if (externalOn) {
            adsrOverlay.hidden = false
            filterOverlay.hidden = false
            fxOverlay.hidden = false
            voiceOverlay.hidden = false

        } else {
            adsrOverlay.hidden = true
            filterOverlay.hidden = true
            fxOverlay.hidden = true
            voiceOverlay.hidden = true
        }

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
    }
    
    @IBAction func filterSwitchActivated(sender: UISwitch) {
        if (sender == lpSwitch && lpSwitch.on) {
            hpSwitch.setOn(false, animated: true)
        } else if (sender == hpSwitch && hpSwitch.on) {
            lpSwitch.setOn(false, animated: true)
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
        let slider1:BWCircularSlider = BWCircularSlider(startColor:UIColor.magentaColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 70.0, y: 370.0, width: 100.0, height: 100.0))
        let slider2:BWCircularSlider = BWCircularSlider(startColor:UIColor.cyanColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 185.0, y: 370.0, width: 100.0, height: 100.0))
        let slider3:BWCircularSlider = BWCircularSlider(startColor:UIColor.redColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 300.0, y: 370.0, width: 100.0, height: 100.0))
        let slider4:BWCircularSlider = BWCircularSlider(startColor:UIColor.purpleColor(), endColor:UIColor.yellowColor(), frame: CGRect(x: 415.0, y: 370.0, width: 100.0, height: 100.0))

        // Attach an Action and a Target to the slider
        slider1.addTarget(self, action: "valueChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Add the slider as subview of this view
        self.view.addSubview(slider1)
        self.view.addSubview(slider2)
        self.view.addSubview(slider3)
        self.view.addSubview(slider4)
       // self.view.bringSubviewToFront(slider1)
        self.view.bringSubviewToFront(adsrOverlay)
        
    }
    #endif
    
    func valueChanged(slider:BWCircularSlider){
        // Do something with the value...
        println("Value changed to \(slider.angle)")
    }

    // END: Circluar Slider //

}
