//
//  Note.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/24/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class Note: UIButton {
    var value : Float!
    var note_name : NSString?
    
    override init(frame f: CGRect) {
        self.value = 0
        super.init(frame: f)
    }
    
    // This should not be used
    required init(coder aDecoder: NSCoder) {
        self.value = 0
        super.init(coder: aDecoder)
    }
    
    func initialize(title: NSString, value : Float, bColor : UIColor) {
        self.setTitle(title, forState: .Normal)
        self.value = value
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.backgroundColor = bColor
        self.layer.cornerRadius = 0.5 * self.bounds.size.width

    }

}
