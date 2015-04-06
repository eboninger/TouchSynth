//
//  MenuBar.swift
//  TouchSynthProject
//
//  Created by Comp150 on 2/25/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class MenuBar: UIView,UIPickerViewDataSource,UIPickerViewDelegate {
    var viewController: ViewController?
    var buttonPreviews: Array<Note>?
    var buttonPreviews2: Array<Note>?
    var addButton: UIButton?
    var colorPalette: Array<UIButton>?
    var noteCount: Int!
    var sequencer: UIView!

    
    
    var typePicker: UIPickerView?
    var pickerData = [
        ["Note", "Scale"],
        ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
        ["1", "2", "3", "4", "5", "6", "7"],
        ["Sharps", "Flats"],
        ["Blues", "Min. Pentatonic", "Maj. Pentatonic", "Major", "Natural Minor", "Melodic Minor", "Harmonic Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Locrian"]
    ]

    override init(frame f: CGRect) {
        noteCount = 0
        super.init(frame: f)
    }
    
    required init(coder aDecoder: NSCoder) {
        noteCount = 0
        super.init(coder: aDecoder)
    }
    
    func initialize(viewController: ViewController, typePicker: UIPickerView, buttonPreviews: Array<Note>,
        buttonPreviews2: Array<Note>, colorPalette: Array<UIButton>, addButton: UIButton)//, sequencer: UIView)
    {
        //self.sequencer = sequencer
        //self.sequencer.hidden = true
        self.viewController = viewController
        self.buttonPreviews = buttonPreviews
        for button in self.buttonPreviews! {
            button.layer.borderWidth = 0
            button.enabled = false
        }
        self.buttonPreviews2 = buttonPreviews2
        for button in self.buttonPreviews2! {
            button.layer.borderWidth = 0
            button.enabled = false
        }
        self.addButton = addButton
        self.addButton!.addTarget(self, action: "addNotes:", forControlEvents: .TouchUpInside)
        for button in self.buttonPreviews! {
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 12)
        }
        for button in self.buttonPreviews2! {
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.titleLabel!.font =  UIFont(name: "Helvetica-BoldOblique", size: 12)
        }
        self.colorPalette = colorPalette
        for color in self.colorPalette! {
            color.layer.cornerRadius = 0.5 * color.bounds.size.width
            color.addTarget(self, action: "changePreviewColors:", forControlEvents: .TouchDown)
        }
        self.typePicker = typePicker
        self.typePicker!.delegate = self
        self.typePicker!.dataSource = self
        self.typePicker!.selectRow(1, inComponent: 0, animated: true)
        self.typePicker!.selectRow(3, inComponent: 1, animated: true)
        self.typePicker!.selectRow(3, inComponent: 2, animated: true)
        self.typePicker!.selectRow(0, inComponent: 3, animated: true)
        self.typePicker!.selectRow(3, inComponent: 4, animated: true)
        updatePreview()

    }
    
    @IBAction func changePreviewColors(sender: UIButton) {
        for button in buttonPreviews! {
            button.backgroundColor = sender.backgroundColor
            if (sender.backgroundColor == UIColor.cyanColor() || sender.backgroundColor == UIColor.greenColor()
                                                              || sender.backgroundColor == UIColor.yellowColor()) {
                button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            } else {
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
        }
        for button in buttonPreviews2! {
            button.backgroundColor = sender.backgroundColor
            if (sender.backgroundColor == UIColor.cyanColor() || sender.backgroundColor == UIColor.greenColor()
                || sender.backgroundColor == UIColor.yellowColor()) {
                    button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            } else {
                button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            }
        }

    }
    
    @IBAction func addNotes(sender: UIButton) {
        var x: CGFloat = 10
        var y: CGFloat = 10
        for i in 0...noteCount - 1 {
            var note = self.buttonPreviews![i]
            self.viewController!.createNote(note.titleForState(.Normal)!, value: note.value, x_loc: x, y_loc: 10,
                tcolor: note.titleColorForState(.Normal)!, bcolor: note.backgroundColor!)
            x += 70
        }

    }

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }

    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: pickerData[component][row], attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])

        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if (component == 4) {
            return 200
            
        }
        return 95
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = pickerData[component][row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica-BoldOblique", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 0) {
            updateLabel()
        }
        updatePreview()
    }
    
    func updatePreview()
    {
        var midiNote: Int = MusicController.noteToMidi(self.typePicker!.selectedRowInComponent(1), octave: self.typePicker!.selectedRowInComponent(2) + 1)
        var showsharps = true
        if (self.typePicker!.selectedRowInComponent(3) == 1) {
            showsharps = false
        }
        // If Note is selected
        if (self.typePicker!.selectedRowInComponent(0) == 0) {
            noteCount = 1
            showNotes()
            buttonPreviews![0].setValue(midiNote, showsharps: showsharps)
            buttonPreviews2![0].setValue(midiNote, showsharps: showsharps)
        }
        // If Scale is selected
        else if (self.typePicker!.selectedRowInComponent(0) == 1) {
            var scalename: String = self.pickerData[4][self.typePicker!.selectedRowInComponent(4)]
            var noteadditions: Array<Int> = MusicController.scale_dictionary[scalename]!
            noteCount = noteadditions.count
            showNotes()
            for i in 0...noteCount - 1 {
                var addition = noteadditions[i]
                buttonPreviews![i].setValue(midiNote + addition, showsharps: showsharps)
                buttonPreviews2![i].setValue(midiNote + addition, showsharps: showsharps)
            }
        }
        //self.sequencer.hidden = true
        //self.sequencer.frame.offset(dx: 0, dy: 150)


    }
    
    func showNotes()
    {
        for i in 0...noteCount - 1 {
            buttonPreviews![i].hidden = false
            buttonPreviews2![i].hidden = false
        }
        
        if (noteCount != 8) {
            for i in noteCount...buttonPreviews!.count - 1 {
                buttonPreviews![i].hidden = true
                buttonPreviews2![i].hidden = true
            }
        }

    }
    
    func updateLabel(){
        if (self.typePicker!.selectedRowInComponent(0) == 0) {
            pickerData = [
                ["Note", "Scale"],
                ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
                ["1", "2", "3", "4", "5", "6", "7"],
                ["Sharps", "Flats"],
                []
            ]
        } else if (self.typePicker!.selectedRowInComponent(0) > 0) {
            pickerData = [
                ["Note", "Scale"],
                ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
                ["1", "2", "3", "4", "5", "6", "7"],
                ["Sharps", "Flats"],
                ["Blues", "Min. Pentatonic", "Maj. Pentatonic", "Major", "Natural Minor", "Melodic Minor", "Harmonic Minor", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Locrian"]
            ]
        }

        self.typePicker!.reloadAllComponents()
        self.typePicker!.selectRow(3, inComponent: 4, animated: true)
        //self.sequencer.hidden = true
        //self.sequencer.frame.offset(dx: 0, dy: 150)



    }
    
    
}
