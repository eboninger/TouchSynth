//
//  Note.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/24/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class Note: ZFRippleButton {
    var value : Int!
    var note_name : NSString?
    var playing : Bool!
    
    override init(frame f: CGRect) {
        self.value = 0
        self.playing = false
        super.init(frame: f)
        self.enabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        self.value = 0
        self.playing = false
        super.init(coder: aDecoder)
        initialize("", value: 10, tColor: UIColor.whiteColor(), bColor: UIColor.purpleColor())
    }
    
    func initialize(title: NSString, value : Int, tColor: UIColor, bColor : UIColor) {
        self.setTitle(title as String, forState: .Normal)
        self.value = value
        self.setTitleColor(tColor, forState: .Normal)
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
    
    func setValue(value: Int, showsharps: Bool) {
        self.value = value
        self.setTitle(MusicController.midiToNote(value, sharp: showsharps), forState: UIControlState.Normal)
    }
    
    func isPlaying() -> Bool {
        return self.playing
    }
    
    func startPlaying() {
        self.playing = true
    }
    
    func stopPlaying() {
        self.playing = false
    }
    
    func containsTouch(point: CGPoint) -> Bool {
        if (point.x > 0 && point.x < self.frame.width && point.y > 0 && point.y < self.frame.height) {
            return true
        }
        return false
    }

}
