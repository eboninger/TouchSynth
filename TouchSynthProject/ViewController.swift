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
    var patch: UnsafeMutablePointer<Void>
    
    var origX: CGFloat?
    var origY: CGFloat?
    
    @IBOutlet weak var playEdit: UISegmentedControl!
    @IBOutlet weak var Logo: UILabel!
    @IBOutlet var collectionOfNotes: Array<Note>!
    @IBOutlet var buttonPreviews: Array<Note>!
    @IBOutlet var colorPalette: Array<UIButton>!
    @IBOutlet var panHandler: UIGestureRecognizer!
    @IBOutlet var menu: MenuBar!
    @IBOutlet var typePicker: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var previewView: UIView!
    @IBOutlet var buttonPreviews2: Array<Note>!
    @IBOutlet var previewView2: UIView!
    @IBOutlet var playView: UIView!
    @IBOutlet var leftButton: Note!
    @IBOutlet var pickerView: UIView!
    
    // need to make this work for trashing notes... currently is touch drag enter button
    @IBOutlet weak var trash_open: UIImageView!
    @IBOutlet weak var trash_closed: UIImageView!
    
    
    required init(coder aDecoder: NSCoder) {
        patch = PdBase.openFile("demo.pd", path: NSBundle.mainBundle().resourcePath)
    
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       self.view.backgroundColor = UIColor(patternImage: UIImage(named:"app_background.jpg")!)
        
        patchID = PdBase.dollarZeroForFile(patch)
        Logo.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
        Logo.textColor = UIColor.darkGrayColor()
        addButton.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 12)
        var attr = NSDictionary(object: UIFont(name: "Helvetica-BoldOblique", size: 16.0)!, forKey: NSFontAttributeName)
        playEdit.setTitleTextAttributes(attr, forState: .Normal)
        trash_open.hidden = true
        trash_closed.hidden = true
        initializePreviewView()
        initializeNotes()
        initializeMenu()
        origX = previewView.frame.minX
        origY = previewView.frame.minY
        previewView2.bringSubviewToFront(previewView)

    }
    
    func initializePreviewView()
    {
        let aSelector : Selector = "handlePreviewViewPan:"
        let panHandler = UIPanGestureRecognizer(target: self, action: aSelector)
        previewView.addGestureRecognizer(panHandler)
    }
    
    func initializeMenu()
    {
        menu.initialize(self, typePicker: typePicker, buttonPreviews: buttonPreviews,
            buttonPreviews2: buttonPreviews2, colorPalette: colorPalette, addButton: addButton)
        menu.layer.cornerRadius = 0.02 * menu.bounds.size.width
        menu.hidden = true
        menu.layer.shadowColor = UIColor.blackColor().CGColor
        menu.layer.shadowOffset = CGSize(width: 1, height: 10)
        menu.layer.shadowOpacity = 0.4
        menu.layer.shadowRadius = 7
    }
    
    func initializeNotes()
    {
        collectionOfNotes = Array<Note>()
        var x_start: CGFloat = 10
        var x_offset: CGFloat = 90
        
        createNote("A3", value: 57, x_loc: x_start, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C4", value: 60, x_loc: x_start + 1 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D4", value: 62, x_loc: x_start + 2 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E4", value: 64, x_loc: x_start + 3 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G4", value: 67, x_loc: x_start + 3.5 * x_offset, y_loc: 300, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("A4", value: 69, x_loc: x_start + 5 * x_offset, y_loc: 300, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C5", value: 72, x_loc: x_start + 5.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D5", value: 74, x_loc: x_start + 6.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E5", value: 76, x_loc: x_start + 7.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G5", value: 79, x_loc: x_start + 8.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
    }
    
    func createNote(title: NSString, value: Int, x_loc: CGFloat, y_loc: CGFloat, tcolor: UIColor, bcolor : UIColor)
    {
        let myNote = Note(frame: CGRectMake(x_loc + 80, y_loc + 130, 75, 105))
        myNote.initialize(title, value: value, tColor: tcolor, bColor: bcolor)
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

    @IBAction func handlePreviewViewPan(recognizer:UIPanGestureRecognizer) {
        recognizer.cancelsTouchesInView = false
        switch(recognizer.state) {
            
        case .Changed:
            let translation = recognizer.translationInView(self.view)
            recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
                y:recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: self.view)
            println(previewView.frame.maxY)
            
        case .Ended:
            var offset: CGFloat = 0
            var point = previewView.convertPoint(CGPoint(x: previewView.frame.minX, y: previewView.frame.minY), toView: playView)
            var curX = previewView.frame.minX + 680
            var curY = previewView.frame.minY + 540
            
            var numNotes: Int = 0
            for note in buttonPreviews2 {
                if (!note.hidden) {
                    numNotes += 1
                } else {
                    break
                }
            }
            
            var space_needed: Int = numNotes * 70 + (numNotes - 1) * 25
            var space_left: Int = Int(playView.frame.maxX) - Int(curX)
            if (space_left < space_needed) {
                offset -= CGFloat(space_needed - space_left)
            }
            
            curX = previewView.frame.minX
            curY = previewView.frame.minY
            if (curX < -655) {
                curX = -655
            }
            if (curY > -97) {
                curY = -97
            } else if (curY < -525) {
                curY = -525
            }
            
            println(curY)
            for note in buttonPreviews {
                if (!note.hidden) {
                    createNote(note.titleForState(.Normal)!, value: note.value, x_loc: curX + 600 + offset, y_loc: curY + 480,
                        tcolor: note.titleColorForState(.Normal)!, bcolor: note.backgroundColor!)
                    offset += 90
                }
            }

            
            previewView.frame.offset(dx: origX! - previewView.frame.minX, dy: origY! - previewView.frame.minY)
            
        default:
            break
            
        }
        
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
        if (playmode) {
            trash_closed.hidden = true
            trash_open.hidden = true
            menu.hidden = true
        } else {
            menu.hidden = false
            trash_closed.hidden = false
        }
    }
    
    @IBAction func playedNote(sender: Note) {
        if (playmode) {
            //PdBase.sendFloat(127, toReceiver: "velocity")
            //PdBase.sendFloat(300, toReceiver: "note2")
            //PdBase.sendFloat(Float(sender.value), toReceiver: "note2")
            //PdBase.sendList([sender.value, 127] as NSArray, toReceiver: "note")
            PdBase.sendFloat(Float(sender.value), toReceiver: "note")
            println("Sent note")
        } else {
            trash_open.hidden = false
            trash_closed.hidden = true
        }
    }
    
    @IBAction func stoppedNote(sender: Note) {
        if (playmode) {
            //PdBase.sendFloat(0, toReceiver: "velocity")
            //PdBase.sendFloat(60, toReceiver: "note2")
            
            PdBase.sendFloat(Float(0), toReceiver: "note")
        } else {
            if (inTrash(sender.frame)) {
                sender.removeFromSuperview()
            }
            trash_open.hidden = true
            trash_closed.hidden = false
        }
    }
    
    func inTrash(bFrame: CGRect) -> Bool {
        var x = (bFrame.minX + bFrame.maxX) / 2
        var y = (bFrame.minY + bFrame.maxY) / 2
        if (x > trash_open.frame.minX && x < trash_open.frame.maxX && y > trash_open.frame.minY && y < trash_open.frame.maxY) {
            return true
        } else {
            return false
        }
    }
}