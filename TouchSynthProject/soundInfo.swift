//
//  soundInfo.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/21/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

struct soundInfo { 
    
    var sound: String!
    var tremolo: Float!
    var reverb: Float!
    var chorus: Float!
    var filterFreq: Int!
    var filterQ : Int!
    var delay: Float!
    var noteCommand: Bool!
    var filterOn: Int!
    var filterType: String!
    var octave: Int!
    var semitone: Int!
    var fine: Int!
    
    init() {
        sound = "piano_1"
        tremolo = 0.0
        reverb = 60
        chorus = 0.0
        delay = 0
        filterFreq = 1000
        filterQ = 1
        delay = 0
        noteCommand = false
        filterOn = 0
        filterType = "lowpass"
        octave = 0
        semitone = 0
        fine = 100
    }
    
}
