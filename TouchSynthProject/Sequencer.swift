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

import AVFoundation


protocol recordingProtocol{
    func recordNote(note: Note, command: recData.command)
    func recordStop()
    func doneRecording() -> [recData.sample]
}

class Sequencer: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    var parentViewController: ViewController?

    var bar: UILabel?
    var beat: UILabel?
    var seqPicker: UIPickerView?
    var pickerData = [
        ["6/8", "5/4", "4/4", "3/4"]
    ]
    
    var recorder : recordingProtocol?
    var recording : [recData.sample]?
    var recordings : [[recData.sample]]?
    var recordingIndex = -1
    var contains_recording = false
    var recDataIndex = 0;
    var is_recording: Bool!
    var is_playing: Bool!
    var pause_state : [CGPoint] = []
    var rec_length : Int = 0
    var timers : [NSTimer] = []
    var pause_time : NSTimeInterval = 0
    var recording_speed: Double = 120
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var metronomeSoundPlayer: AVAudioPlayer!
    var metronomeSoftSoundPlayer: AVAudioPlayer!
    var beatCount = 0
    var metronome = true
    
    var savedRecordingsPicker: SavedRecordingsPicker?
    var savedRecordingsTableView: UITableView?
    
    required init(coder aDecoder: NSCoder) {
        self.is_recording = false
        self.is_playing = false
        super.init(coder: aDecoder)
        initializePickerData()
        
        
        // Initialize the sound player
        let metronomeSoftSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("metroClickSoft", ofType: "wav")!)
        metronomeSoftSoundPlayer = AVAudioPlayer(contentsOfURL: metronomeSoftSoundURL, error: nil)
        metronomeSoftSoundPlayer.prepareToPlay()
        
        // Initialize the sound player
        let metronomeSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("metroClick", ofType: "wav")!)
        metronomeSoundPlayer = AVAudioPlayer(contentsOfURL: metronomeSoundURL, error: nil)
        metronomeSoundPlayer.prepareToPlay()

    }
    
    func initialize(parentViewController: ViewController, seqPicker: UIPickerView, bar: UILabel, beat: UILabel, savedRecordingsPicker: SavedRecordingsPicker, savedRecordingsTableView: UITableView)
    {
        self.parentViewController = parentViewController
        self.seqPicker = seqPicker
        self.seqPicker!.delegate = self
        self.seqPicker!.dataSource = self
        self.seqPicker!.selectRow(2, inComponent: 0, animated: true)
        self.seqPicker!.selectRow(120, inComponent: 1, animated: true)
        self.bar = bar
        self.beat = beat
        self.recordings = []
        self.savedRecordingsPicker = savedRecordingsPicker
        self.savedRecordingsTableView = savedRecordingsTableView
        
        self.savedRecordingsPicker!.initialize(self, tableView: self.savedRecordingsTableView!, recordings: self.recordings!)
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

    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        let pickerLabel = UILabel()
        let titleData = pickerData[component][row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica-BoldOblique", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            var bpm = Double(pickerData[component][row].toInt()!)
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 75
    }
    
    func isRecording() -> Bool {
        return self.is_recording
    }
    
    func isPlaying() -> Bool {
        return self.is_playing
    }
    
    func startRecording()
    {
        self.seqPicker!.userInteractionEnabled = false
        recorder = record()
        self.is_recording = true
        startTimer()


    }
    
    func stop()
    {
        self.contains_recording = true
        self.seqPicker!.userInteractionEnabled = true
        recorder?.recordStop()
        recording = recorder?.doneRecording()
        recDataIndex = 0
        recorder = nil
        stopTimer()
        self.is_recording = false
        recording_speed = Double(self.pickerData[1][self.seqPicker!.selectedRowInComponent(1)].toInt()!)
        self.beatCount = 0
        
        recordings!.append(recording!)
        savedRecordingsPicker!.updateData(self.recordings!)
    }
    
    func containsRecording() -> Bool {
        return contains_recording
    }
    
    func startPlayback()
    {
        NSLog("Pause time: " + String(stringInterpolationSegment: pause_time))
        if (self.recording == nil) {
            return
        }
        self.is_playing = true
        startTimer()
        rec_length = recording!.count
        for var i = recDataIndex; i < rec_length; i++ {
            var s = recording![i];
            
            let params = ["note" : s.note, "value" : s.note_value]
            var timer = NSTimer()
            var timeRatio: Double = recording_speed / Double(self.pickerData[1][self.seqPicker!.selectedRowInComponent(1)].toInt()!)
            var fireAfter = (s.elapsed_time - pause_time) * timeRatio
            if(s.cmd == recData.command.ON){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("playNoteInPlayback:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            else if(s.cmd == recData.command.OFF){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("stopNoteInPlayback:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            
            else if(s.cmd == recData.command.STOP){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("endOfPlayback:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            
            // NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes) // use this so the NSTimer can execute concurrently with UIChanges
            
            
        }
    }
    
    func pausePlayback(){
        for timer in timers {
            timer.invalidate()
        }
        timers = []
        is_playing = false
        pause_time = recording![recDataIndex].elapsed_time
        parentViewController!.playButton.setBackgroundImage(UIImage(named:"play.png")!, forState: .Normal)
    }
    
    func endOfPlayback(timer: NSTimer) {
        stopTimer()
        self.is_playing = false
        pause_time = 0
        recDataIndex = 0
        parentViewController!.playButton.setBackgroundImage(UIImage(named:"play.png")!, forState: .Normal)
        parentViewController!.recordButton.enabled = true
        self.beatCount = 0
    }
    
    func playNoteInPlayback(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let note = userInfo["note"] as! Note
        let note_value = userInfo["value"] as! Int
        var touch = UITouch()
        self.parentViewController!.playedNote(note, touch: touch)
        recDataIndex++

    }
    
    func stopNoteInPlayback(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let note = userInfo["note"] as! Note
        let note_value = userInfo["value"] as! Int
        var touch = UITouch()
        
        self.parentViewController!.stoppedNote(note, touch: touch)
        recDataIndex++
    }
    
    func recordNoteOn(note: Note) {
        if (isRecording()) {
            recorder?.recordNote(note, command: recData.command.ON)
        }

    }
    
    func recordNoteOff(note: Note) {
        if (isRecording()) {
            recorder?.recordNote(note, command: recData.command.OFF)
        }

    }
    
    func startTimer()
    {
        if timer.valid {
            return
        }
        var bpm: Double = Double(self.pickerData[1][self.seqPicker!.selectedRowInComponent(1)].toInt()!)
        
        var timeSigString = self.pickerData[0][self.seqPicker!.selectedRowInComponent(0)]
        var fullTimeSig = split(timeSigString) {$0 == "/"}
        var beatsPerBar = fullTimeSig[0].toInt()
        var timePerBeat = fullTimeSig[1].toInt()
        
        var frequency: NSTimeInterval = (60 / bpm) / Double(timePerBeat! / 4)
                let aSelector : Selector = "updateTime"
        if self.metronome {
            metronomeSoundPlayer.play()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(frequency, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    func stopTimer()
    {
        timer.invalidate()
        self.bar!.text = "0001."
        self.beat!.text = "1"
    }
    
    func pauseTimer()
    {
        timer.invalidate()
        self.beatCount++
    }
    
    func pressedBack()
    {
        stopTimer()
    }
    
    
    func toggleMetronome() {
        self.metronome = !self.metronome
    }
    
    func updateTime()
    {
        
        if !isRecording() && !isPlaying() {
            if (recDataIndex > 0) {
                pauseTimer()
            } else {
                stopTimer()
            }
            return
        }
        self.beatCount += 1
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var timeSigString = self.pickerData[0][self.seqPicker!.selectedRowInComponent(0)]
        var fullTimeSig = split(timeSigString) {$0 == "/"}
        var beatsPerBar = fullTimeSig[0].toInt()
        var timePerBeat = fullTimeSig.count > 1 ? fullTimeSig[1].toInt() : 0
        
        self.bar!.text = String(format: "%04d", self.beatCount / beatsPerBar! + 1) + "."
        self.beat!.text = String(self.beatCount % beatsPerBar! + 1)

        if self.metronome {
            if (self.beatCount % beatsPerBar! == 0) {
                metronomeSoundPlayer.play()
            } else {
                metronomeSoftSoundPlayer.play()
            }
        }

    }
    
}
