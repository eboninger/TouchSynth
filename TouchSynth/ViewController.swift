//
//  ViewController.swift
//  TouchSynth
//
//  Created by Stephanie Cleland on 2/10/15.
//  Copyright (c) 2015 Stephanie Cleland. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var Controller: UISegmentedControl!
 
    @IBOutlet weak var editView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChangeLabel(sender: AnyObject) {
        if Controller.selectedSegmentIndex == 0 {
            editView.hidden = true;
        }
        if Controller.selectedSegmentIndex == 1 {
            editView.hidden = false;
        }
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
            y:recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    @IBAction func handleTap(recognizer:UITapGestureRecognizer) {
        let alertController = UIAlertController(title: "Butoon", message: "Hi there", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}