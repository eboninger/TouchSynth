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
    var patchID : Int32 = 0
    var patch = PdBase.openFile("demo.pd", path: NSBundle.mainBundle().resourcePath)
    
    @IBOutlet var collectionOfNotes: Array<Note>!
    @IBOutlet var buttonPreviews: Array<UIButton>!
    @IBOutlet var colorPalette: Array<UIButton>!
    @IBOutlet var myCaption: UILabel!
    @IBOutlet var panHandler: UIGestureRecognizer!
    @IBOutlet var menu: MenuBar!
    @IBOutlet var typePicker: UIPickerView!
    @IBOutlet var specsPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        patchID = PdBase.dollarZeroForFile(patch)
        initializeNotes()
        initializeMenu()
    }
    
    func initializeMenu()
    {
        menu.initialize(typePicker, buttonPreviews: buttonPreviews, colorPalette: colorPalette)
        menu.layer.cornerRadius = 0.02 * menu.bounds.size.width
        menu.hidden = true
    }
    
    func initializeNotes()
    {
        collectionOfNotes = Array<Note>()
        createNote("A3", value: 57, x_loc: 100, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("C4", value: 60, x_loc: 170, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("D4", value: 62, x_loc: 240, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("E4", value: 64, x_loc: 310, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("G4", value: 67, x_loc: 345, y_loc: 300, bcolor : UIColor.blueColor())
        createNote("A4", value: 69, x_loc: 465, y_loc: 300, bcolor : UIColor.blueColor())
        createNote("C5", value: 72, x_loc: 500, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("D5", value: 74, x_loc: 570, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("E5", value: 76, x_loc: 640, y_loc: 200, bcolor : UIColor.blueColor())
        createNote("G5", value: 79, x_loc: 710, y_loc: 200, bcolor : UIColor.blueColor())
    }
    
    func createNote(title: NSString, value: Float, x_loc: CGFloat, y_loc: CGFloat, bcolor : UIColor)
    {
        let myNote = Note(frame: CGRectMake(x_loc + 80, y_loc + 130, 50, 70))
        myNote.initialize(title, value: value, bColor: bcolor)
        myNote.addTarget(self, action: "playedNote:", forControlEvents: .TouchDown)
        myNote.addTarget(self, action: "stoppedNote:", forControlEvents: .TouchUpInside)
        myNote.addTarget(self, action: "stoppedNote:", forControlEvents: .TouchDragExit)
        let aSelector : Selector = "handlePan:"
        let panHandler = UIPanGestureRecognizer(target: self, action: aSelector)
        myNote.addGestureRecognizer(panHandler)
        self.view.addSubview(myNote)
        collectionOfNotes.append(myNote)
    }
    
    func pressed(sender: UIButton!) {
        var alertView = UIAlertView();
        alertView.addButtonWithTitle("Ok");
        alertView.title = "title";
        alertView.message = "message";
        alertView.show();
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
        menu.toggle()
    }
    
    @IBAction func playedNote(sender: Note) {
        if (playmode) {
            myCaption.text = "Playing "  + sender.titleLabel!.text!
            PdBase.sendFloat(sender.value, toReceiver: "note")
        }
    }
    
    @IBAction func stoppedNote(sender: Note) {
        if (playmode) {
            myCaption.text = "Stopped playing \(sender.titleLabel!.text!)"
            PdBase.sendFloat(0, toReceiver: "note")
        }
    }
}