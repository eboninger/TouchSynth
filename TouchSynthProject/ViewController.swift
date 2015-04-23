//
//  ViewController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/19/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

// Data stored for each soundfont
struct SfData {
    var name: String
    var color: UIColor
    
    // ... other parameters go here ...
}

class ViewController: UIViewController {
    
    var playmode = true;
    var patchID : Int32 = 0
    var patch: UnsafeMutablePointer<Void>
    var path = NSBundle.mainBundle().resourcePath! + "/"
//    let soundfonts = ["analog_age", "banjo_1", "beautiful_pad", "bolivianflute", "Campbells_strings", "Campbells_Verby_Vocal", "church_organ", "DCs_Mellotron_Flute", "ElPiano1", "enigma_flute", "flugelhorn", "janos_lead", "jonnypad1", "jonnypad3", "jonnypad4", "jonnypad5", "jonnypad6", "jonnypad7", "jonnypad8", "LesPaul", "piano_1", "muted_trombone", "saz", "SC88Drumset", "StomperSet"]
    
    var origX: CGFloat?
    var origY: CGFloat?
    
    var first_time = true
    var recording = false
    var metronome = true
    
    var info = soundInfo()

    @IBOutlet weak var hide_seq: UIButton!
    @IBOutlet weak var show_seq: UIButton!
    @IBOutlet weak var hide_menu: UIButton!
    @IBOutlet weak var show_menu: UIButton!
    
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
    @IBOutlet var deleteAllButton: UIButton!
    var settingsPage: SettingsViewController!
    
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    //sequencer bar
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var bar: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var beat: UILabel!
    @IBOutlet weak var beatLabel: UILabel!
    
    
    @IBOutlet weak var trash_open: UIImageView!
    @IBOutlet weak var trash_closed: UIImageView!
    
    var notificationKey = "soundInfo"
    let nc = NSNotificationCenter.defaultCenter()
    

    required init(coder aDecoder: NSCoder) {
        
        // Add all patches in the main bundle to Pd's search path, set up externals (needed for [soundfonts])
        PdBase.addToSearchPath(NSBundle.mainBundle().resourcePath)
        PdExternals.setup()
        
      //  patch = PdBase.openFile("final_patch.pd", path: NSBundle.mainBundle().resourcePath)
        patch = PdBase.openFile("SFPatch.pd", path: NSBundle.mainBundle().resourcePath)
        
        super.init(coder: aDecoder)
        
        nc.addObserver(self, selector: "updateSoundInfo:", name: notificationKey, object: nil)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        settingsPage = storyboard.instantiateViewControllerWithIdentifier("SettingsPage") as! SettingsViewController


    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"app_background.jpg")!)
        
        patchID = PdBase.dollarZeroForFile(patch)
        bpm.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        Logo.font = UIFont(name: "Helvetica-BoldOblique", size: 32)
        Logo.textColor = UIColor.lightGrayColor()
        Logo2.font = UIFont(name: "Helvetica-BoldOblique", size: 32)
        Logo2.textColor = UIColor.darkGrayColor()
        VolumeLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        VolumeLabel.textColor = UIColor.darkGrayColor()
        deleteAllButton.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        deleteAllButton.titleLabel!.textColor = UIColor.darkGrayColor()
        dragLabel.enabled = false
        dragLabel.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 12)
        dragLabel.titleLabel!.textColor = UIColor.whiteColor()
        stationaryPreviewView.sendSubviewToBack(dragLabel)
        var attr = NSDictionary(object: UIFont(name: "Helvetica-BoldOblique", size: 16.0)!, forKey: NSFontAttributeName)
        playEdit.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
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
        
        settingsButton.setBackgroundImage(UIImage(named:"settings.png")!, forState: .Normal)
        settingsButton.setTitle("", forState: .Normal)
        infoButton.setBackgroundImage(UIImage(named:"info.png")!, forState: .Normal)
        infoButton.setTitle("", forState: .Normal)

        
        // sequencer bar setup
        playButton.setBackgroundImage(UIImage(named:"play.png")!, forState: .Normal)
        backButton.setBackgroundImage(UIImage(named:"back.png")!, forState: .Normal)
        recordButton.setBackgroundImage(UIImage(named:"record.png")!, forState: .Normal)
        metronomeButton.setBackgroundImage(UIImage(named:"metronome_on.png")!, forState: .Normal)
        playButton.setTitle("", forState: .Normal)
        backButton.setTitle("", forState: .Normal)
        recordButton.setTitle("", forState: .Normal)
        metronomeButton.setTitle("", forState: .Normal)
        bar.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
        barLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        beat.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
        beatLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        
        show_seq.hidden = true
        show_menu.hidden = true
        hide_menu.hidden = true
        show_seq.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        hide_seq.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        hide_menu.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        show_menu.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)

        initializePd()

    }
    
    func sendString(message: String, toReceiver: String) {
        
        var finalMessage = [AnyObject]()
        for item in message.componentsSeparatedByString(" ") {
            
            // If the element is a number append it as a Float, otherwise as a String
            var number = (item as NSString).floatValue
            if item.toInt() == nil {
                finalMessage.append(item)
            } else {
                finalMessage.append(number)
            }
        }
        
        PdBase.sendList(finalMessage, toReceiver: "note")
    }
    
    func initializePd()
    {
        PdBase.sendList(["set", "\(path + info.sound).sf2"], toReceiver: "soundfont")
        volumeController.value = 0.5
        PdBase.sendFloat(0.5, toReceiver: "volume")
        
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
            buttonPreviews2: buttonPreviews2, colorPalette: colorPalette, addButton: dragLabel)//, sequencer: sequencer)
        menu.layer.cornerRadius = 0.02 * menu.bounds.size.width

        menu.layer.shadowColor = UIColor.blackColor().CGColor
        menu.layer.shadowOffset = CGSize(width: 1, height: 10)
        menu.layer.shadowOpacity = 0.4
        menu.layer.shadowRadius = 7
        menu.alpha = 0
        menu.bringSubviewToFront(stationaryPreviewView)
        stationaryPreviewView.bringSubviewToFront(previewView)
    }
    
    func initializeSequencer()
    {
        sequencer.initialize(self, seqPicker: seqPicker, bar: bar, beat: beat)
        sequencer.layer.cornerRadius = 0.02 * sequencer.bounds.size.width
        
        sequencer.layer.shadowColor = UIColor.blackColor().CGColor
        sequencer.layer.shadowOffset = CGSize(width: 1, height: 10)
        sequencer.layer.shadowOpacity = 0.4
        sequencer.layer.shadowRadius = 7
        sequencer.hidden = false
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
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        for note in collectionOfNotes {
            note.hidden = true
        }
                self.presentViewController(settingsPage, animated: true, completion: nil)
        
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
        
        var note = recognizer.view
        switch(recognizer.state) {
        
        case .Began:
            playView.bringSubviewToFront(note!)
            bringControlsToFront()
            trash_open.hidden = false
            trash_closed.hidden = true
            
        case .Changed:
            let translation = recognizer.translationInView(self.view)
            recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
                y:recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: self.view)
            
        case .Ended:
            if (inTrash(note!.frame)) {
                note!.removeFromSuperview()
            }
            trash_open.hidden = true
            trash_closed.hidden = false
            
        default:
            break
        }
        
        
        
    }
    
    
    @IBAction func editPressed(sender: AnyObject) {
        playmode = !playmode;

        if (playmode) {
            for note in collectionOfNotes {
                note.enabled = false
            }
            trash_closed.hidden = true
            trash_open.hidden = true
            deleteAllButton.hidden = true
            show_seq.hidden = true
            hide_seq.hidden = false
            show_menu.hidden = true
            hide_menu.hidden = true
            UIView.animateWithDuration(0.5, animations: {
                self.menu.alpha = 0
                self.sequencer.alpha = 1
            })
            //self.menu.hidden = true
            self.sequencer.hidden = false
            /*
            UIView.animateWithDuration(0.5, animations: {
                self.menu.frame.offset(dx: 0, dy: 150)
                self.sequencer.hidden = false
                self.sequencer.frame.offset(dx: 0, dy: -150)
            }) */
        } else {
            show_seq.hidden = true
            hide_seq.hidden = true
            show_menu.hidden = true
            hide_menu.hidden = false
            for note in collectionOfNotes {
                note.enabled = true
            }
            self.menu.hidden = false
            //self.sequencer.hidden = true
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showTrash"), userInfo: self, repeats: false)
            UIView.animateWithDuration(0.5, animations: {
                self.menu.alpha = 1
                self.sequencer.alpha = 0
            })
            self.view.bringSubviewToFront(menu)
            
            /* Stuff for animated transitions
            if (first_time) {
                self.menu.hidden = false
                self.menu.frame.offset(dx: 0, dy: 150)
                //self.sequencer.frame.offset(dx: 0, dy: 300)
                first_time = false
            }
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showTrash"), userInfo: self, repeats: false)
            UIView.animateWithDuration(0.5, animations: {
                self.menu.frame.offset(dx: 0, dy: -150)
                self.sequencer.frame.offset(dx: 0, dy: 150)
            })
            End stuff */

        }
    }
    
    func showTrash() {
        trash_closed.hidden = false
        deleteAllButton.hidden = false
    }
    
    func soundfontChanged(soundfont: String) {
        PdBase.sendList(["set", "\(path + soundfont).sf2"], toReceiver: "soundfont")
        info.sound = soundfont
    }
    
    func updateSoundInfo (notification:NSNotification) {
        let userInfo:Dictionary<String, AnyObject> = notification.userInfo as! Dictionary<String, AnyObject>
        let soundFont  = userInfo["sound"] as! String!
        PdBase.sendList(["set", "\(path + soundFont).sf2"], toReceiver: "soundfont")
        let filterFreq  = userInfo["filterFreq"] as! Int!
        PdBase.sendList(["filter_frequency", filterFreq], toReceiver: "filter_freq")
        let filterQ  = userInfo["filterQ"] as! Int!
        PdBase.sendList(["filter_q", filterQ], toReceiver: "filter_q")
        let reverb  = userInfo["reverb"] as! Float!
        PdBase.sendList(["reverb_level", reverb], toReceiver: "reverb")
        
    }
    
    @IBAction func playedNote(sender: Note, touch: UITouch) {
        if (playmode) {
            PdBase.sendList([Float(sender.value), 127], toReceiver: "note")
            sender.beginTrackingWithTouch(touch)
            if (sequencer!.isRecording()) {
                sequencer!.recordNoteOn(sender)
            }
            
        }
    }
    
    func bringControlsToFront()
    {
        playView.bringSubviewToFront(volumeController)
        playView.bringSubviewToFront(VolumeLabel)
    }
    
    @IBAction func stoppedNote(sender: Note, touch: UITouch) {
        if (playmode) {
            var patch_name : String?
            patch_name = "banjo_1"
            PdBase.sendList([Float(sender.value), 0], toReceiver: "note")
            sender.endTrackingWithTouch(touch)
            if (sequencer!.isRecording()) {
                sequencer!.recordNoteOff(sender)
            }
        }
    }
    
    @IBAction func volumeChanged(sender: UISlider) {
        PdBase.sendFloat(sender.value, toReceiver: "volume")
    }
    
    @IBAction func hideSequencer(sender:UIButton) {
        if (hide_seq.hidden == true) {
            self.sequencer.hidden = false
            hide_seq.hidden = false
            show_seq.hidden = true

        } else {
            self.sequencer.hidden = true
            hide_seq.hidden = true
            show_seq.hidden = false
        }
    }
    
    @IBAction func hideMenu(sender:UIButton) {
        if (hide_menu.hidden == true) {
            self.menu.hidden = false
            hide_menu.hidden = false
            show_menu.hidden = true
            trash_closed.hidden = false
            trash_open.hidden = false
            deleteAllButton.hidden = false
            
        } else {
            self.menu.hidden = true
            hide_menu.hidden = true
            show_menu.hidden = false
            trash_closed.hidden = true
            trash_open.hidden = true
            deleteAllButton.hidden = true
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
    
    @IBAction func pressedPlay(sender: UIButton) {
        if (!sequencer.containsRecording()) {
            return
        }
        if (!sequencer.isPlaying()) {
            recordButton.enabled = false
            sender.setBackgroundImage(UIImage(named:"pause.png")!, forState: .Normal)
            sequencer!.startPlayback()
        } else {
            sender.setBackgroundImage(UIImage(named:"play.png")!, forState: .Normal)
            sequencer!.pausePlayback()
        }
        
    }
    
    @IBAction func pressedRecord(sender: UIButton) {
        if (!sequencer.isRecording()) {
            sender.setBackgroundImage(UIImage(named:"stop.png")!, forState: .Normal)
            sequencer!.startRecording()
            playButton.enabled = false
            backButton.enabled = false
        } else {
            sender.setBackgroundImage(UIImage(named:"record.png")!, forState: .Normal)
            sequencer!.stop()
            playButton.enabled = true
            backButton.enabled = true
        }

    }
    
    @IBAction func pressedBack(sender: UIButton) {
        sequencer!.pressedBack()
    }
    
    @IBAction func pressedMetronome(sender: UIButton) {
        metronome = !metronome
        if (metronome) {
            sender.setBackgroundImage(UIImage(named:"metronome_on.png")!, forState: .Normal)
        } else {
            sender.setBackgroundImage(UIImage(named:"metronome.png")!, forState: .Normal)
        }
        self.sequencer.toggleMetronome()
    }
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
        for note in collectionOfNotes {
            note.hidden = false
        }
        let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }

    @IBAction func showInfoPage(sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: "About Touch Synth", message: "Created by the one and only Brett Fischler, Eli Boninger, and Steph Cleland abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz", preferredStyle: .Alert)
        
        alertController.view.tintColor = UIColor.magentaColor()

 
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Close", style: .Cancel) { action -> Void in
        }
        alertController.addAction(cancelAction)


        
        //Present the AlertController
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /***************** Touch stuff ******************/
    
    
    // Creates new note if not touching existing note, otherwise makes that note current
    
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!playmode) {
            return
        }
        for note in collectionOfNotes {
            var touched = false
            var cur_touch : UITouch = UITouch()
            for touch in event.allTouches()! {
                let t = touch as! UITouch
                var locationPoint = t.locationInView(note)
                if note.containsTouch(locationPoint) {
                    touched = true
                    cur_touch = t
                }
            }
            if (touched && note.isPlaying() == false) {
                    playedNote(note, touch: cur_touch)
                
                    note.startPlaying()
            } else if (!touched && note.isPlaying()) {
                    stoppedNote(note, touch: cur_touch)
                    note.stopPlaying()
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!playmode) {
            return
        }
        var count = 0
        for note in collectionOfNotes {
            var touched = false
            var cur_touch : UITouch = UITouch()
            for touch in event.allTouches()! {
                let t = touch as! UITouch
                var locationPoint = t.locationInView(note)
                if note.containsTouch(locationPoint) {
                    count += 1
                    touched = true
                    cur_touch = t
                }
            }
            if (touched && note.isPlaying() == false) {
                playedNote(note, touch: cur_touch)
                note.startPlaying()
            } else if (!touched && note.isPlaying()) {
                stoppedNote(note, touch: cur_touch)
                note.stopPlaying()
            }
        }
    }
    

    
    // Stop playing the note if it wasn't a drag from a sustain
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!playmode) {
            return
        }
        for note in collectionOfNotes {

            for touch in touches {
                let t = touch as! UITouch
                var locationPoint = t.locationInView(note)
                if note.containsTouch(locationPoint) && note.isPlaying() {
                    stoppedNote(note, touch: t)
                    note.stopPlaying()
                }
            }
        }
    }
}
    
  