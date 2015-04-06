//
//  Sequencer.swift
//  TouchSynthProject
//
//  Created by Comp150 on 3/29/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import CoreBluetooth
import CoreAudio
//import "CoreAudioKit/CABTMIDILocalPeripheralViewController.h"

import UIKit

class Sequencer: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    var deviceManager: MIKMIDIDeviceManager?
    var sequencer: MIKMIDISequencer?
    var sequence: MIKMIDISequence?
    var seqPicker: UIPickerView?
    var pickerData = [
        ["5/4", "4/4", "3/4"]
    ]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.deviceManager = MIKMIDIDeviceManager.sharedDeviceManager()
        NSLog("About to print virtual resources:")
        for device in self.deviceManager!.virtualSources {
            NSLog(device.model)
        }
        NSLog("Done printing virtual resources")
        NSLog("About to print available devices:")
        for device in self.deviceManager!.availableDevices {
            NSLog(device.model)
        }
        NSLog("Done printing available devices")
        self.sequence = MIKMIDISequence()
        self.sequencer = MIKMIDISequencer(sequence: self.sequence!)
        initializePickerData()
    }
    
    func initialize(seqPicker: UIPickerView)
    {
        self.seqPicker = seqPicker
        self.seqPicker!.delegate = self
        self.seqPicker!.dataSource = self
        self.seqPicker!.selectRow(1, inComponent: 0, animated: true)
        self.seqPicker!.selectRow(120, inComponent: 1, animated: true)
        //self.seqPicker!.selectRow(3, inComponent: 2, animated: true)
        //self.seqPicker!.selectRow(0, inComponent: 3, animated: true)
        //self.seqPicker!.selectRow(3, inComponent: 4, animated: true)
    }
    
    func initializePickerData() {
        var numList: Array<String> = []
        for i in 40...240 {
            numList.append(String(280 - i))
        }
        pickerData.append(numList)
        
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
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if (component == 4) {
            return 200
        }
        return 95
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[component][row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica-BoldOblique", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
    
}
