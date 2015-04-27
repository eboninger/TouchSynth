//
//  soundInfo.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/21/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

struct soundInfo {
    
    enum command {
        case ON
        case OFF
        case IGNORE
    }
    
    var sound: String!
    var tremolo: Float!
    var reverb: Float!
    var chorus: Float!
    var filterFreq: Int!
    var filterQ : Int!
    var delay: Float!
    var noteCommand: command
    
    init() {
        sound = "piano_1"
        tremolo = 0
        reverb = 0
        chorus = 0
        filterFreq = 0
        filterQ = 0
        delay = 0
        noteCommand = command.IGNORE
    }
    
}