//
//  ViewController.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/19/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import CoreData

import UIKit

// Data stored for each soundfont
struct SfData {
    var name: String
    var color: UIColor
    
    // ... other parameters go here ...
}

class ViewController: UIViewController {
    
    @IBOutlet var savedDataPicker: SavedDataPicker!
    @IBOutlet var savedDataTableView: UITableView!
    
    var coreNotes = [NSManagedObject]()
    var coreNoteCollections = [NSManagedObject]()
    
    
    var settingsmode = false
    var playmode = true
    var patchID : Int32 = 0
    var patch: UnsafeMutablePointer<Void>
    var path = NSBundle.mainBundle().resourcePath! + "/"
    
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
    @IBOutlet weak var saveDataButton: UIButton!
    @IBOutlet weak var saveLayoutButton: UIButton!
    @IBOutlet weak var closeSaveDataWindow: UIButton!
    
    //sequencer bar
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var bar: UILabel!
    @IBOutlet weak var barLabel: UILabel!
    @IBOutlet weak var beat: UILabel!
    @IBOutlet weak var beatLabel: UILabel!
    
    
    @IBOutlet var savedRecordingsPicker: SavedRecordingsPicker!
    @IBOutlet var savedRecordingsTableView: UITableView!
    @IBOutlet weak var recordingsButton: UIButton!
    @IBOutlet weak var curRecordingLabel: UILabel!
    
    
    @IBOutlet weak var trash_open: UIImageView!
    @IBOutlet weak var trash_closed: UIImageView!
    
    var notificationKey = "soundInfo"
    let nc = NSNotificationCenter.defaultCenter()
    
    var octave = 0
    var semitone = 0
    var fine = 0

    required init(coder aDecoder: NSCoder) {
        
        // Add all patches in the main bundle to Pd's search path, set up externals (needed for [soundfonts])
        PdBase.addToSearchPath(NSBundle.mainBundle().resourcePath)
        PdExternals.setup()
        
      //  patch = PdBase.openFile("final_patch.pd", path: NSBundle.mainBundle().resourcePath)
        patch = PdBase.openFile("SFPatchFX.pd", path: NSBundle.mainBundle().resourcePath)
        
        super.init(coder: aDecoder)
        
        nc.addObserver(self, selector: "updateSoundInfo:", name: notificationKey, object: nil)
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        settingsPage = storyboard.instantiateViewControllerWithIdentifier("SettingsPage") as! SettingsViewController


    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        initializeSavedDataPicker()
        initializeSequencer()
        origX = previewView.frame.minX
        origY = previewView.frame.minY
        stationaryPreviewView.bringSubviewToFront(previewView)
        volumeController.minimumValue = 0
        volumeController.maximumValue = 8
        volumeController.value = 4
        NSLog("Value: \(volumeController.value)")
        
        // TOP MENU BAR STUFF
        settingsButton.setBackgroundImage(UIImage(named:"settings.png")!, forState: .Normal)
        settingsButton.setTitle("", forState: .Normal)
        infoButton.setBackgroundImage(UIImage(named:"info.png")!, forState: .Normal)
        infoButton.setTitle("", forState: .Normal)
        savedDataPicker.hidden = true
        saveLayoutButton.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        closeSaveDataWindow.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        saveDataButton.setBackgroundImage(UIImage(named:"save.png")!, forState: .Normal)
        saveDataButton.setTitle("", forState: .Normal)
        
        savedRecordingsPicker.layer.shadowColor = UIColor.blackColor().CGColor
        savedRecordingsPicker.layer.shadowOffset = CGSize(width: -1, height: 6)
        savedRecordingsPicker.layer.shadowOpacity = 0.4
        savedRecordingsPicker.layer.shadowRadius = 5
        
        savedDataPicker.layer.shadowColor = UIColor.blackColor().CGColor
        savedDataPicker.layer.shadowOffset = CGSize(width: -1, height: 6)
        savedDataPicker.layer.shadowOpacity = 0.4
        savedDataPicker.layer.shadowRadius = 5
        
        
        savedRecordingsPicker.hidden = true
        curRecordingLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        recordingsButton.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        
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
        curRecordingLabel.textAlignment = NSTextAlignment.Center
        
        show_seq.hidden = true
        show_menu.hidden = true
        hide_menu.hidden = true
        show_seq.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        hide_seq.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        hide_menu.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        show_menu.titleLabel!.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        self.view.bringSubviewToFront(show_seq)
        self.view.bringSubviewToFront(show_menu)
        self.view.bringSubviewToFront(hide_seq)
        self.view.bringSubviewToFront(hide_menu)
        
        self.view.bringSubviewToFront(sequencer)

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
        PdBase.sendFloat(4, toReceiver: "volume")
        
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
    
    func initializeSavedDataPicker()
    {
        savedDataPicker.initialize(self, tableView: savedDataTableView)
        loadCoreNoteCollections()
    }
    
    func initializeSequencer()
    {
        sequencer.initialize(self, seqPicker: seqPicker, bar: bar, beat: beat, savedRecordingsPicker: savedRecordingsPicker, savedRecordingsTableView: savedRecordingsTableView)
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
        var x_start: CGFloat = 90
        var x_offset: CGFloat = 90
        
        createNote("A3", value: 57, x_loc: x_start, y_loc: 320, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C4", value: 60, x_loc: x_start + 1 * x_offset, y_loc: 280, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D4", value: 62, x_loc: x_start + 2 * x_offset, y_loc: 280, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E4", value: 64, x_loc: x_start + 3 * x_offset, y_loc: 305, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G4", value: 67, x_loc: x_start + 3.5 * x_offset, y_loc: 430, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("A4", value: 69, x_loc: x_start + 5 * x_offset, y_loc: 430, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("C5", value: 72, x_loc: x_start + 5.5 * x_offset, y_loc: 305, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("D5", value: 74, x_loc: x_start + 6.5 * x_offset, y_loc: 280, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("E5", value: 76, x_loc: x_start + 7.5 * x_offset, y_loc: 280, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        createNote("G5", value: 79, x_loc: x_start + 8.5 * x_offset, y_loc: 320, tcolor : UIColor.whiteColor(), bcolor : UIColor.purpleColor())
        for note in collectionOfNotes {
            note.enabled = false
        }
    }
    
    func createNote(title: NSString, value: Int, x_loc: CGFloat, y_loc: CGFloat, tcolor: UIColor, bcolor : UIColor)
    {
        let myNote = Note(frame: CGRectMake(x_loc, y_loc, 75, 105))
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
        settingsmode = true
        savedDataPicker.hidden = true
        savedRecordingsPicker.hidden = true
        self.presentViewController(settingsPage, animated: true, completion: nil)
        
    }
    
    @IBAction func recordingsButtonPressed(sender: UIButton) {
        savedRecordingsPicker.hidden = !savedRecordingsPicker.hidden
        self.view.bringSubviewToFront(savedRecordingsPicker)
        
    }
    
    /** SAVED DATA MENU STUFF **/
    @IBAction func saveDataButtonPressed(sender: UIButton) {
        savedDataPicker.hidden = !savedDataPicker.hidden
        playView.bringSubviewToFront(savedDataPicker)
        
    }
    
    @IBAction func closeSaveDataButtonPressed(sender: UIButton) {
        savedDataPicker.hidden = true
    }
    
    @IBAction func saveLayoutButtonPressed(sender: UIButton) {
        saveCoreNoteCollection()
        savedDataPicker.hidden = true
    }
    /** END SAVED DATA MENU STUFF **/
    
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
                    createNote(note.titleForState(.Normal)!, value: note.value, x_loc: curX + 680 + offset, y_loc: curY + 610,
                        tcolor: note.titleColorForState(.Normal)!, bcolor: note.backgroundColor!)
                    offset += 90
                }
            }
            
            bringControlsToFront()
            playView.bringSubviewToFront(savedDataPicker) // AHHH

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
            playView.bringSubviewToFront(savedDataPicker) // AHHH
            if (!self.menu.hidden) {
                trash_open.hidden = false
                trash_closed.hidden = true
            }
            
        case .Changed:
            let translation = recognizer.translationInView(self.view)
            recognizer.view!.center = CGPoint(x:recognizer.view!.center.x + translation.x,
                y:recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPointZero, inView: self.view)
            
        case .Ended:
            if (inTrash(note!.frame)) {
                for i in 0...collectionOfNotes.count {
                    if (collectionOfNotes[i] == note) {
                        collectionOfNotes.removeAtIndex(i)
                        break
                    }
                }
                note!.removeFromSuperview()
            }
            if (!self.menu.hidden) {
                trash_open.hidden = true
                trash_closed.hidden = false
            }
            
        default:
            break
        }
        
        
        
    }
    
    
    @IBAction func editPressed(sender: AnyObject) {
        playmode = !playmode;
        savedDataPicker.hidden = true
        savedRecordingsPicker.hidden = true

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
            self.sequencer.hidden = false
        } else {
            show_seq.hidden = true
            hide_seq.hidden = true
            show_menu.hidden = true
            hide_menu.hidden = false
            for note in collectionOfNotes {
                note.enabled = true
            }
            self.menu.hidden = false
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showTrash"), userInfo: self, repeats: false)
            UIView.animateWithDuration(0.5, animations: {
                self.menu.alpha = 1
                self.sequencer.alpha = 0
            })
            self.view.bringSubviewToFront(menu)
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
        PdBase.sendList([filterFreq], toReceiver: "filter_freq")
        let filterQ  = userInfo["filterQ"] as! Int!
        PdBase.sendList([filterQ], toReceiver: "filter_q")
        let reverb  = userInfo["reverb"] as! Float!
        PdBase.sendList([reverb], toReceiver: "reverb_feedback")
        
        let delay = userInfo["delay"] as! Float!
        PdBase.sendList(["time", delay], toReceiver: "delay_time")
        
        let tremolo  = userInfo["tremolo"] as! Float!
        PdBase.sendList(["rate", tremolo], toReceiver: "tremolo_rate")
        
        let chorus  = userInfo["chorus"] as! Float!
        PdBase.sendList(["chorus_amount", chorus], toReceiver: "chorus")
        
        let filterType = userInfo["filterType"] as! String!
        NSLog("ABOUT TO SEND FILTER TYPE \(filterType)")
        PdBase.sendList([filterType], toReceiver: "filter_type")
        
        let filterOn = userInfo["filterOn"] as! Int!
        PdBase.sendList([filterOn], toReceiver: "filter_on")
        
        self.octave = userInfo["octave"] as! Int!
        self.semitone = userInfo["semitone"] as! Int!
        
        var fine = userInfo["fine"] as! Float!
        fine = (fine / 100) + 63
        NSLog("fine: \(fine)")
        PdBase.sendList(["fine_tune", fine], toReceiver: "fine_tune")

        let note = userInfo["note"] as! Note!
        let playNote = userInfo["playNote"] as! Bool!
        if (playNote!) {
            for note in collectionOfNotes {

            }
            playedNote(note, touch: UITouch())
        } else {
            stoppedNote(note, touch: UITouch())
        }
        
    }
    
    @IBAction func playedNote(sender: Note, touch: UITouch) {
        //if (playmode) {
            let noteToPlay = sender.value + (12 * self.octave) + self.semitone
            PdBase.sendList([noteToPlay, 127], toReceiver: "note")
            sender.beginTrackingWithTouch(touch)
            if (sequencer!.isRecording()) {
                sequencer!.recordNoteOn(sender)
            }
            
       // }
    }
    
    func bringControlsToFront()
    {
        playView.bringSubviewToFront(volumeController)
        playView.bringSubviewToFront(VolumeLabel)
    }
    
    @IBAction func stoppedNote(sender: Note, touch: UITouch) {
        //if (playmode) {
            let noteToStop = sender.value + (12 * self.octave) + self.semitone
            PdBase.sendList([noteToStop, 0], toReceiver: "note")
            sender.endTrackingWithTouch(touch)
            if (sequencer!.isRecording()) {
                sequencer!.recordNoteOff(sender)
            }
        //}
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
            trash_open.hidden = true
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
        settingsmode = false
        let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }

    @IBAction func showInfoPage(sender: AnyObject) {
        let font:UIFont? = UIFont.boldSystemFontOfSize(12.0)
        
        var message = "Play Mode: \n Simply press the notes to make them play! \n Sequencer:\n If you want to record your music, press the record button to begin recording, and press it again once you're done recording. Your new recording will automatically be added to the list of recordings, which you can load or delete by pressing the recordings button. The recording you currently have selected will be listed on the left.\n Edit Mode:\n To add new notes, move current notes around, or delete notes from the screen, enter edit mode! Here you will have the option of adding a scale or a note, choose the key and octave, sharps or flats, and the type of scale. Then simply drag and drop it to add it to the screen. \n Save:\n If you want to save a current note layout, or load a previously saved note layout, just press the floppy disk at the top of the screen. Each note layout is listed by the date and time it was saved. \n Settings:\n To change the sound of your notes, enter the settings page. From here you can choose a preset sound, or play around with the settings until you get a sound you like!"
        
        let alertController: UIAlertController = UIAlertController(title: "About touchSYNTH", message: message, preferredStyle: .Alert)
        
       // alertController.
        alertController.view.tintColor = UIColor.magentaColor()

 
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Close", style: .Cancel) { action -> Void in
        }
        alertController.addAction(cancelAction)


        
        //Present the AlertController
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    /***********************/
    /*** TOUCH FUNCTIONS ***/
    /***********************/

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        savedDataPicker.hidden = true
        savedRecordingsPicker.hidden = true
        if (!playmode || settingsmode) {
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
        if (!playmode || settingsmode) {
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
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (!playmode || settingsmode) {
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
    
    /***************************/
    /*** CORE DATA FUNCTIONS ***/
    /***************************/
    
    @IBAction func savePressed(sender: AnyObject!)
    {
        
    }
    
    func displayCoreNotes() {
        for note in coreNotes {
            var backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(note.valueForKey("bcolor") as! NSData) as! UIColor
            var textColor = NSKeyedUnarchiver.unarchiveObjectWithData(note.valueForKey("tcolor") as! NSData) as! UIColor
            createNote(note.valueForKey("title") as! String,
                value: note.valueForKey("value") as! Int,
                x_loc: CGFloat(note.valueForKey("x") as! Int),
                y_loc: CGFloat(note.valueForKey("y") as! Int),
                tcolor: textColor,
                bcolor: backgroundColor)
        }
    }
    
    func deleteCoreNotes() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        for note in coreNotes {
            managedContext.deleteObject(note)
            NSLog("Deleted note!")
        }
        managedContext.save(nil)
    }
    
    func deleteCoreCollectionAtIndex(index: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        managedContext.deleteObject(coreNoteCollections[index])
        coreNoteCollections.removeAtIndex(index)
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not delete \(error), \(error?.userInfo)")
        }
    }
    
    func saveCoreNoteCollection() {
        let title = getDate()
        for note in collectionOfNotes {
            saveCoreNote(note, collection: title)
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("NoteCollection", inManagedObjectContext: managedContext)
        let mycollection = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)

        mycollection.setValue(title, forKey: "title")
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        } else {
            loadCoreNoteCollections()
        }
    }
    
    func getDate() -> String
    {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .MediumStyle
        return formatter.stringFromDate(date)
    }
    
    func saveCoreNote(note: Note, collection: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: managedContext)
        let mynote = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        mynote.setValue(note.value, forKey: "value")
        mynote.setValue(note.titleLabel!.text, forKey: "title")
        var backgroundColor = NSKeyedArchiver.archivedDataWithRootObject(note.backgroundColor!)
        var textColor = NSKeyedArchiver.archivedDataWithRootObject(note.titleLabel!.textColor)
        mynote.setValue(backgroundColor, forKey: "bcolor")
        mynote.setValue(textColor, forKey: "tcolor")
        mynote.setValue(note.frame.minX, forKey: "x")
        mynote.setValue(note.frame.minY, forKey: "y")
        mynote.setValue(collection, forKey: "collection")
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        } else {
            NSLog("Saved note!")
        }
    }
    
    func loadCoreNoteCollections() {
        NSLog("Called load core note collections")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"NoteCollection")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            coreNoteCollections = results
            savedDataPicker.updateData(coreNoteCollections)
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func loadCollectionWithTitle(title: String) {
        savedDataPicker.hidden = true
        while (collectionOfNotes.count > 0) {
            collectionOfNotes[0].removeFromSuperview()
            collectionOfNotes.removeAtIndex(0)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Note")
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        if let results = fetchedResults {
            coreNotes = results
            for note in coreNotes {
                var mytitle = note.valueForKey("collection") as! String
                if (note.valueForKey("collection") as! String == title) {
                    var backgroundColor = NSKeyedUnarchiver.unarchiveObjectWithData(note.valueForKey("bcolor") as! NSData) as! UIColor
                    var textColor = NSKeyedUnarchiver.unarchiveObjectWithData(note.valueForKey("tcolor") as! NSData) as! UIColor
                    createNote(note.valueForKey("title") as! String,
                        value: note.valueForKey("value") as! Int,
                        x_loc: CGFloat(note.valueForKey("x") as! Int),
                        y_loc: CGFloat(note.valueForKey("y") as! Int),
                        tcolor: textColor,
                        bcolor: backgroundColor)
                } else {
                }
            }
            if (playmode) {
                for note in collectionOfNotes {
                    note.enabled = false
                }
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
    }

}
    
  