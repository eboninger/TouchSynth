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
    func doneRecording() -> [recData.sample]
}

class Sequencer: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    var parentViewController: ViewController?
    var deviceManager: MIKMIDIDeviceManager?
    var sequencer: MIKMIDISequencer?
    var sequence: MIKMIDISequence?
    var bar: UILabel?
    var beat: UILabel?
    var seqPicker: UIPickerView?
    var pickerData = [
        ["5/4", "4/4", "3/4"]
    ]
    
    var recorder : recordingProtocol?
    var recording : [recData.sample]?
    var recordingIndex = 0;
    var is_recording: Bool!
    var is_playing: Bool!
    var pause_state : [CGPoint] = []
    var rec_length : Int = 0
    var timers : [NSTimer] = []
    var pause_time : NSTimeInterval = 0
    
    var timer = NSTimer()
    var startTime = NSTimeInterval()
    var metronomeSoundPlayer: AVAudioPlayer!
    var beatCount = 0
    var metronome = false
    
    required init(coder aDecoder: NSCoder) {
        self.is_recording = false
        self.is_playing = false
        super.init(coder: aDecoder)
        self.sequence = MIKMIDISequence()
        self.sequencer = MIKMIDISequencer(sequence: self.sequence!)
        self.sequencer!.sequence.setTempo(120, atTimeStamp:0)
        self.sequencer!.recordEnabledTracks = NSSet(object: sequence!.addTrack()) as Set<NSObject>
        self.sequencer!.clickTrackStatus = MIKMIDISequencerClickTrackStatus.Disabled
        initializePickerData()
        
        
        // Initialize the sound player
        let metronomeSoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("metronomeClick", ofType: "mp3")!)
        metronomeSoundPlayer = AVAudioPlayer(contentsOfURL: metronomeSoundURL, error: nil)
        metronomeSoundPlayer.prepareToPlay()

    }
    
    func initialize(parentViewController: ViewController, seqPicker: UIPickerView, bar: UILabel, beat: UILabel)
    {
        self.parentViewController = parentViewController
        self.seqPicker = seqPicker
        self.seqPicker!.delegate = self
        self.seqPicker!.dataSource = self
        self.seqPicker!.selectRow(1, inComponent: 0, animated: true)
        self.seqPicker!.selectRow(120, inComponent: 1, animated: true)
        self.bar = bar
        self.beat = beat
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
        if component == 1 {
            var bpm = Double(pickerData[component][row].toInt()!)
            self.sequencer!.sequence.setTempo(bpm, atTimeStamp:0)
        }
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
        startTimer()
        self.is_recording = true
        //self.sequencer!.preRoll = 0
        //self.sequencer!.recordEnabledTracks = NSSet(object: sequence!.addTrack())
        //sequencer!.startRecording()

    }
    
    func stop()
    {
        self.seqPicker!.userInteractionEnabled = true
        recording = recorder?.doneRecording()
        recorder = nil
        stopTimer()
        self.is_recording = false
        //sequencer!.stop()
    }
    
    func startPlayback()
    {
        //sequencer!.startPlayback()
        self.is_playing = true
        startTimer()
        rec_length = recording!.count
        for var i = recordingIndex; i < rec_length; i++ {
            var s = recording![i];
            
            let params = ["note" : s.note, "value" : s.note_value]
            var timer = NSTimer()
            var fireAfter = s.elapsed_time - pause_time
            if(s.cmd == recData.command.ON){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("playNoteInPlayback:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            else if(s.cmd == recData.command.OFF){
                timer = NSTimer.scheduledTimerWithTimeInterval(fireAfter, target: self, selector : Selector("stopNoteInPlayback:"), userInfo: params, repeats: false)
                timers.append(timer)
            }
            // NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes) // use this so the NSTimer can execute concurrently with UIChanges
            
            
        }
    }
    
    func playNoteInPlayback(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let note = userInfo["note"] as! Note
        let note_value = userInfo["value"] as! Int
        var touch = UITouch()
        self.parentViewController!.playedNote(note, touch: touch)
        
        
        //createNote(pt, isPlayback: true)
        //recordingIndex++
        //if(recordingIndex == rec_length){
        //    recordingIndex = 0
        //    inPlayback = false
        //    pause_time = 0
        //    (parentViewController as InstrumentViewController).resetPlayButton()
       // }
    }
    
    func stopNoteInPlayback(timer: NSTimer){
        var userInfo = timer.userInfo as! NSDictionary
        let note = userInfo["note"] as! Note
        let note_value = userInfo["value"] as! Int
        var touch = UITouch()
        
        self.parentViewController!.stoppedNote(note, touch: touch)
    }
    
    func recordNoteOn(note: Note) {
        if (isRecording()) {
            recorder?.recordNote(note, command: recData.command.ON)
            NSLog("Lol we're recording soemthing")
        }
        
        /*
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
        NSLog("Added note on")*/
    }
    
    func recordNoteOff(note: Note) {
        if (isRecording()) {
            recorder?.recordNote(note, command: recData.command.OFF)
        }
        /*
        let noteOff = MIKMutableMIDINoteOffCommand()
        noteOff.timestamp = NSDate()
        noteOff.channel = 1
        noteOff.note = UInt(note.value)
        self.sequencer!.recordMIDICommand(noteOff)
        NSLog("Added note off")*/
    }
    
    func startTimer()
    {
        if timer.valid {
            return
        }
        var bpm: Double = Double(self.pickerData[1][self.seqPicker!.selectedRowInComponent(1)].toInt()!)
        var frequency: NSTimeInterval = 60 / bpm
                let aSelector : Selector = "updateTime"
        if self.metronome {
            metronomeSoundPlayer.play()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(frequency, target: self, selector: aSelector, userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        self.beatCount = 0
    }
    
    func stopTimer()
    {
        
        timer.invalidate()
        self.bar!.text = "0000."
        self.beat!.text = "0"
    }
    
    func pressedBack()
    {
        sequencer!.stop()
        stopTimer()
    }
    
    
    func toggleMetronome() {
        self.metronome = !self.metronome
    }
    
    func updateTime()
    {
        if !isRecording() && !isPlaying() {
            stopTimer()
            return
        }
        self.beatCount += 1
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var timeSigString = self.pickerData[0][self.seqPicker!.selectedRowInComponent(0)]
        var fullTimeSig = split(timeSigString) {$0 == "/"}
        var beatsPerBar = fullTimeSig[0].toInt()
        var timePerBeat = fullTimeSig.count > 1 ? fullTimeSig[1].toInt() : 0
        
        self.bar!.text = String(format: "%04d", self.beatCount / beatsPerBar!) + "."
        self.beat!.text = String(self.beatCount % beatsPerBar!)
        
        if self.metronome {
            metronomeSoundPlayer.play()
        }

        //Find the difference between current time and start time.
        /*var elapsedTime: NSTimeInterval = currentTime - self.startTime
        
        
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
        NSLog("TIME: \(strMinutes):\(strSeconds):\(strFraction)")*/
        

    }
    
}
