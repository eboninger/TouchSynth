//
//  recData.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/14/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

class recData {
    enum command {
        case ON
        case OFF
        case STOP
    }
    
    struct sample{
        var elapsed_time: NSTimeInterval
        var note_value: Int
        var note: Note
        var cmd: command
    }
}