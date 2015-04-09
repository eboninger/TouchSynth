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


import UIKit

class Sequencer: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    var deviceManager: MIKMIDIDeviceManager?
    var sequencer: MIKMIDISequencer?
    var sequence: MIKMIDISequence?
    var seqPicker: UIPickerView?
    var pickerData = [
        ["5/4", "4/4", "3/4"]
    ]
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sequence = MIKMIDISequence()
        self.sequencer = MIKMIDISequencer(sequence: self.sequence!)
        self.sequencer!.recordEnabledTracks = NSSet(object: sequence!.addTrack())
        self.sequencer!.clickTrackStatus = MIKMIDISequencerClickTrackStatus.AlwaysEnabled
        initializePickerData()
        /*self.deviceManager = MIKMIDIDeviceManager.sharedDeviceManager()
        NSLog("About to print virtual resources:")
        for device in self.deviceManager!.virtualSources {
            NSLog(device.model)
        }
        NSLog("Done printing virtual resources")
        NSLog("About to print available devices:")
        for device in self.deviceManager!.availableDevices {
            NSLog(device.model)
        }
        NSLog("Done printing available devices")*/

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
    
    func isRecording() -> Bool {
        return sequencer!.recording
    }
    
    func startRecording()
    {
        self.sequencer!.preRoll = 0
        //self.sequencer!.recordEnabledTracks = NSSet(object: sequence!.addTrack())
        sequencer!.startRecording()
        startTimer()
    }
    
    func stop()
    {
        NSLog("About to stop")
        sequencer!.stop()
        NSLog("Stopped")
    }
    
    func startPlayback()
    {
        sequencer!.startPlayback()
    }
    
    func recordNoteOn(note: Note) {
        let noteOn = MIKMutableMIDINoteOnCommand()
        noteOn.timestamp = NSDate()
        noteOn.channel = 1
        noteOn.note = UInt(note.value)
        noteOn.velocity = 127
        self.sequencer!.recordMIDICommand(noteOn)
        
        //let noteOff = MIKMutableMIDINoteOffCommand()
        //noteOff.timestamp = NSDate(timeInterval: 1, sinceDate: noteOn.timestamp)
        //noteOff.channel = noteOn.channel
        //noteOff.note = noteOn.note
        
        self.sequencer!.recordMIDICommand(noteOn)
        NSLog("Added note on")
    }
    
    func recordNoteOff(note: Note) {
        let noteOff = MIKMutableMIDINoteOffCommand()
        noteOff.timestamp = NSDate()
        noteOff.channel = 1
        noteOff.note = UInt(note.value)
        self.sequencer!.recordMIDICommand(noteOff)
        NSLog("Added note off")
    }
    
    func startTimer()
    {
        
    }
    
    func updateTime()
    {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - self.startTime
        
        
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction):"0" + String(fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        NSLog("TIME: \(strMinutes):\(strSeconds):\(strFraction)")
    }
    
}
