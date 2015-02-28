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
        self.layer.shadowColor = UIColor.darkGrayColor().CGColor
        self.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 0.5 * self.bounds.size.width).CGPath
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
        self.layer.borderWidth = 2
        self.layer.borderColor = (UIColor.darkGrayColor()).CGColor
        self.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 20)


    }
    
    

}
