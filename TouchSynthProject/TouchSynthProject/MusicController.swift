//
//  MusicController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/27/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

private let _MusicControllerSharedInstance = MusicController()

class MusicController {
    let scale_dictionary: [String: Array<Int>] = [
        "Major": [0, 4, 7, 12, 16],
        "Pentatonic": [0, 3, 5, 7, 10],
        "Blues": [0, 0, 0, 0, 0]
    ]
    
    let accidentals = [false, true, false, false, true, false, true, false, false, true, false, true]
    
    let sharps = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    let flats = ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"]
    
    init() {
        println(midiToNote(0, sharp: true))
    }
    
    func midiToNote(value: Int, sharp: Bool) -> String {
        var noteName: String
        if (sharp) {
            noteName = sharps[(value + 3) % 12]
        } else {
            noteName = flats[(value + 3) % 12]
        }
        noteName += String(((value) / 12) - 1)
        return noteName
    }
    
    func noteToMidi(noteIndex: Int, octave: Int) -> Int {
        var midinote = (noteIndex + 9) % 12
        return ((octave + 1) * 12) + midinote
        
    }
    
    
}