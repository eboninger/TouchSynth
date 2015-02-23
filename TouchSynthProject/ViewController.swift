//
//  ViewController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/19/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class ViewController: UIViewController {
    
    var playmode = true;
    
    
    @IBOutlet var collectionOfButtons: Array<UIButton>!
    @IBOutlet var myCaption: UILabel!
    @IBOutlet var panHandler: UIGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var i = 0
        for button in collectionOfButtons {
            let aSelector : Selector = "handlePan:"
            let panHandler = UIPanGestureRecognizer(target: self, action: aSelector)
            button.addGestureRecognizer(panHandler)
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        recognizer.cancelsTouchesInView = false
        if (playmode) {
            return
        }
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    
    @IBAction func editPressed(sender: AnyObject) {
        playmode = !playmode;
    }
    
    @IBAction func playedNote(sender: UIButton) {
        if (playmode) {
            myCaption.text = "Playing "  + sender.titleLabel!.text!
        }
    }
    
    @IBAction func stoppedNote(sender: UIButton) {
        if (playmode) {
            myCaption.text = "Stopped playing \(sender.titleLabel!.text!)"
        }
    }
}