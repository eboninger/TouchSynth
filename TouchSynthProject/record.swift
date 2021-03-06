//
//  record.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/14/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

class record: recordingProtocol{
    var samples : [recData.sample]
    var timer : NSTimer
    var beginTime : NSDate
    
    
    
    init(){
        samples = []
        timer = NSTimer()
        beginTime = NSDate()
    }
    
    
    func doneRecording() -> [recData.sample]{
        return samples
    }
    
    func recordNote(note: Note, command: recData.command) {
        let new_sample = recData.sample(elapsed_time: -(beginTime.timeIntervalSinceNow) , note_value: note.value, note: note, cmd: command)
        samples.append(new_sample)
        
    }
    
    func recordStop() {
        let new_sample = recData.sample(elapsed_time: -(beginTime.timeIntervalSinceNow) , note_value: 0, note: Note(), cmd: recData.command.STOP)
        samples.append(new_sample)
    }
    
}
