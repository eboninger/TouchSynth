//
//  MusicController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/27/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class MusicController {
    class var scale_dictionary: [String: Array<Int>] { return [
        "Major": [0, 2, 4, 5, 7, 9, 11, 12],
        "Pentatonic": [0, 3, 5, 7, 10, 12],
        "Blues": [0, 3, 5, 6, 7, 10, 12]
        ] }
    
    class var accidentals: Array<Bool> { return [false, true, false, false, true, false, true, false, false, true, false, true] }
    
    class var sharps: Array<String> { return ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"] }
    class var flats: Array<String> { return ["A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"] }
    
    init() {
    }
    
    class func midiToNote(value: Int, sharp: Bool) -> String {
        var noteName: String
        if (sharp) {
            noteName = sharps[(value + 3) % 12]
        } else {
            noteName = flats[(value + 3) % 12]
        }
        noteName += String(((value) / 12) - 1)
        return noteName
    }
    
    class func noteToMidi(noteIndex: Int, octave: Int) -> Int {
        var midinote = (noteIndex + 9) % 12
        return ((octave + 1) * 12) + midinote
        
    }

}