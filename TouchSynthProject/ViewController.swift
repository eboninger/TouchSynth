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
    
    var first_time = true
    var recording = false
    var metronome = false

    
    //@IBOutlet weak var TremoloLabel: UILabel!
    @IBOutlet weak var VolumeLabel: UILabel!
    @IBOutlet weak var playEdit: UISegmentedControl!
    @IBOutlet weak var Logo: UILabel!
    @IBOutlet weak var Logo2: UILabel!
    @IBOutlet weak var bpm: UILabel!
    @IBOutlet var collectionOfNotes: Array<Note>!
    @IBOutlet var buttonPreviews: Array<Note>!
    @IBOutlet var colorPalette: Array<UIButton>!
    @IBOutlet var panHandler: UIGestureRecognizer!
    @IBOutlet var menu: MenuBar!
    @IBOutlet var sequencer: Sequencer!
    @IBOutlet var typePicker: UIPickerView!
    @IBOutlet var seqPicker: UIPickerView!
    @IBOutlet weak var dragLabel: UIButton!
    @IBOutlet var previewView: UIView!
    @IBOutlet var buttonPreviews2: Array<Note>!
    @IBOutlet var stationaryPreviewView: UIView!
    @IBOutlet var playView: UIView!
    @IBOutlet var leftButton: Note!
    @IBOutlet var pickerView: UIView!
    @IBOutlet var volumeController: UISlider!
   // @IBOutlet var tremoloController: UISlider!
    @IBOutlet var deleteAllButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    //sequencer bar
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var Bar: UILabel!
    @IBOutlet weak var BarLabel: UILabel!
    @IBOutlet weak var Beat: UILabel!
    @IBOutlet weak var BeatLabel: UILabel!
    
    
    @IBOutlet weak var trash_open: UIImageView!
    @IBOutlet weak var trash_closed: UIImageView!
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    
    
    required init(coder aDecoder: NSCoder) {
        patch = PdBase.openFile("final_patch.pd", path: NSBundle.mainBundle().resourcePath)
    
        super.init(coder: aDecoder)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"app_background.jpg")!)
        
        patchID = PdBase.dollarZeroForFile(patch)
        bpm.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        //bpm.textColor = UIColor.whiteColor()
        Logo.font = UIFont(name: "Helvetica-BoldOblique", size: 32)
        Logo.textColor = UIColor.lightGrayColor()
        Logo2.font = UIFont(name: "Helvetica-BoldOblique", size: 32)
        Logo2.textColor = UIColor.darkGrayColor()
        VolumeLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        VolumeLabel.textColor = UIColor.darkGrayColor()
        //TremoloLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        //TremoloLabel.textColor = UIColor.darkGrayColor()
        deleteAllButton.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        deleteAllButton.titleLabel!.textColor = UIColor.darkGrayColor()
        dragLabel.enabled = false
        dragLabel.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 12)
        dragLabel.titleLabel!.textColor = UIColor.whiteColor()
        stationaryPreviewView.sendSubviewToBack(dragLabel)
        var attr = NSDictionary(object: UIFont(name: "Helvetica-BoldOblique", size: 16.0)!, forKey: NSFontAttributeName)
        playEdit.setTitleTextAttributes(attr, forState: .Normal)
        trash_open.hidden = true
        trash_closed.hidden = true
        deleteAllButton.hidden = true
        initializePreviewView()
        initializeNotes()
        initializeMenu()
        initializeSequencer()
        origX = previewView.frame.minX
        origY = previewView.frame.minY
        stationaryPreviewView.bringSubviewToFront(previewView)
        volumeController.minimumValue = 0
        volumeController.maximumValue = 1
      //  tremoloController.minimumValue = 0
      //  tremoloController.maximumValue = 20
        
        settingsButton.setBackgroundImage(UIImage(named:"settings.png")!, forState: .Normal)
        settingsButton.setTitle("", forState: .Normal)
        infoButton.setBackgroundImage(UIImage(named:"info.png")!, forState: .Normal)
        infoButton.setTitle("", forState: .Normal)

        
        // sequencer bar setup
        playButton.setBackgroundImage(UIImage(named:"play.png")!, forState: .Normal)
        backButton.setBackgroundImage(UIImage(named:"back.png")!, forState: .Normal)
        recordButton.setBackgroundImage(UIImage(named:"record.png")!, forState: .Normal)
        metronomeButton.setBackgroundImage(UIImage(named:"metronome.png")!, forState: .Normal)
        playButton.setTitle("", forState: .Normal)
        backButton.setTitle("", forState: .Normal)
        recordButton.setTitle("", forState: .Normal)
        metronomeButton.setTitle("", forState: .Normal)
        Bar.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
        BarLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        Beat.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
        BeatLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)



        
        initializePd()

    }
    
    func initializePd()
    {
        PdBase.sendFloat(0.5, toReceiver: "volumeLevel")
        volumeController.value = 0.5
      //  PdBase.sendFloat(0, toReceiver: "tremoloLevel")
    //    tremoloController.value = 0
        //PdBase.sendFloat
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
            buttonPreviews2: buttonPreviews2, colorPalette: colorPalette, addButton: dragLabel)
        menu.layer.cornerRadius = 0.02 * menu.bounds.size.width

        menu.layer.shadowColor = UIColor.blackColor().CGColor
        menu.layer.shadowOffset = CGSize(width: 1, height: 10)
        menu.layer.shadowOpacity = 0.4
        menu.layer.shadowRadius = 7
        menu.hidden = true
        //previewView.layer.zPosition = 1000
        menu.bringSubviewToFront(stationaryPreviewView)
        stationaryPreviewView.bringSubviewToFront(previewView)
    }
    
    func initializeSequencer()
    {
        sequencer.initialize(seqPicker)
        sequencer.layer.cornerRadius = 0.02 * menu.bounds.size.width
        
        sequencer.layer.shadowColor = UIColor.blackColor().CGColor
        sequencer.layer.shadowOffset = CGSize(width: 1, height: 10)
        sequencer.layer.shadowOpacity = 0.4
        sequencer.layer.shadowRadius = 7
        sequencer.hidden = false
        //previewView.layer.zPosition = 1000
    }
    
    func initializeNotes()
    {
        collectionOfNotes = Array<Note>()
        var x_start: CGFloat = 10
        var x_offset: CGFloat = 90
        
        createNote("A3", value: 57, x_loc: x_start, y_loc: 190, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C4", value: 60, x_loc: x_start + 1 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D4", value: 62, x_loc: x_start + 2 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E4", value: 64, x_loc: x_start + 3 * x_offset, y_loc: 175, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G4", value: 67, x_loc: x_start + 3.5 * x_offset, y_loc: 300, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("A4", value: 69, x_loc: x_start + 5 * x_offset, y_loc: 300, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C5", value: 72, x_loc: x_start + 5.5 * x_offset, y_loc: 175, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D5", value: 74, x_loc: x_start + 6.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E5", value: 76, x_loc: x_start + 7.5 * x_offset, y_loc: 150, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G5", value: 79, x_loc: x_start + 8.5 * x_offset, y_loc: 190, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
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
        playView.addSubview(myNote)
        collectionOfNotes.append(myNote)
    }
    
    @IBAction func deleteAllNotes(sender: UIButton) {
        while (collectionOfNotes.count > 0) {
            collectionOfNotes[0].removeFromSuperview()
            collectionOfNotes.removeAtIndex(0)
        }
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

        
            if (curY < -525) {
                curY = -525
            }
            
            for note in buttonPreviews {
                if (!note.hidden && curY < -75) {
                    createNote(note.titleForState(.Normal)!, value: note.value, x_loc: curX + 600 + offset, y_loc: curY + 480,
                        tcolor: note.titleColorForState(.Normal)!, bcolor: note.backgroundColor!)
                    offset += 90
                }
            }
            
            bringControlsToFront()

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
            deleteAllButton.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                self.menu.hidden = false
                self.menu.frame.offset(dx: 0, dy: 150)
                self.sequencer.frame.offset(dx: 0, dy: -150)
            })
        } else {
            if (first_time) {
                self.menu.frame.offset(dx: 0, dy: 150)
                first_time = false
            }
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showTrash"), userInfo: self, repeats: false)
            UIView.animateWithDuration(0.5, animations: {
                self.menu.hidden = false
                self.menu.frame.offset(dx: 0, dy: -150)
                self.sequencer.frame.offset(dx: 0, dy: 150)
            })

        }
    }
    
    func showTrash() {
        trash_closed.hidden = false
        deleteAllButton.hidden = false
    }
    
    @IBAction func playedNote(sender: Note) {
        if (playmode) {
            PdBase.sendList([Float(sender.value), 127], toReceiver: "note")
            
        } else {
            playView.bringSubviewToFront(sender)
            bringControlsToFront()
            trash_open.hidden = false
            trash_closed.hidden = true
        }
    }
    
    func bringControlsToFront()
    {
        playView.bringSubviewToFront(volumeController)
        playView.bringSubviewToFront(VolumeLabel)
      //  playView.bringSubviewToFront(tremoloController)
       // playView.bringSubviewToFront(TremoloLabel)
    }
    
    @IBAction func stoppedNote(sender: Note) {
        if (playmode) {
            PdBase.sendList([Float(sender.value), 0], toReceiver: "note")
        } else {
            if (inTrash(sender.frame)) {
                sender.removeFromSuperview()
            }
            trash_open.hidden = true
            trash_closed.hidden = false
        }
    }
    
    @IBAction func volumeChanged(sender: UISlider) {
        PdBase.sendFloat(sender.value, toReceiver: "volumeLevel")
    }
    
    //@IBAction func tremoloChanged(sender: UISlider) {
     //   PdBase.sendFloat(sender.value, toReceiver: "tremoloLevel")
   // }
    
    
    func inTrash(bFrame: CGRect) -> Bool {
        var x = (bFrame.minX + bFrame.maxX) / 2
        var y = (bFrame.minY + bFrame.maxY) / 2
        if (x > trash_open.frame.minX && x < trash_open.frame.maxX && y > trash_open.frame.minY && y < trash_open.frame.maxY) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func pressedRecord(sender: UIButton) {
        recording = !recording
        if (recording) {
            sender.setBackgroundImage(UIImage(named:"stop.png")!, forState: .Normal)
        } else {
            sender.setBackgroundImage(UIImage(named:"record.png")!, forState: .Normal)
        }

    }
    
    @IBAction func pressedMetronome(sender: UIButton) {
        metronome = !metronome
        if (metronome) {
            sender.setBackgroundImage(UIImage(named:"metronome_on.png")!, forState: .Normal)
        } else {
            sender.setBackgroundImage(UIImage(named:"metronome.png")!, forState: .Normal)
        }
        
    }
}