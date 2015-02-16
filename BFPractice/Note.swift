//
//  Note.swift
//  BFPractice
//
//  Created by Comp150 on 2/11/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import UIKit

class Note: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTitle("Button!", forState: UIControlState.Normal)
    }

}
