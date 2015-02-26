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
    
    var buttonPreviews: Array<UIButton>?
    var colorPalette: Array<UIButton>?
    
    var typePicker: UIPickerView?
    //var specsPicker: UIPickerView?
    var pickerData = [
        ["Note", "Scale", "Chord"],
        ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
        ["1", "2", "3", "4", "5", "6", "7"],
        ["Blues", "Pentatonic", "Major"]
    ]

    override init(frame f: CGRect) {
        super.init(frame: f)
    }
    
    // This should not be used
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize(typePicker: UIPickerView, buttonPreviews: Array<UIButton>, colorPalette: Array<UIButton>)
    {
        self.buttonPreviews = buttonPreviews
        for button in self.buttonPreviews! {
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
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
        self.typePicker!.selectRow(2, inComponent: 1, animated: true)
        self.typePicker!.selectRow(3, inComponent: 2, animated: true)
        self.typePicker!.selectRow(1, inComponent: 3, animated: true)

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
    }
    
    func toggle()
    {
        self.hidden = !self.hidden
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
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 0) {
            updateLabel()
        }
        updatePreview()
    }
    
    func updatePreview()
    {
        if (self.typePicker!.selectedRowInComponent(0) == 0) {
            buttonPreviews![0].hidden = true
            buttonPreviews![1].hidden = true
            buttonPreviews![3].hidden = true
            buttonPreviews![4].hidden = true
            var notename = self.pickerData[1][self.typePicker!.selectedRowInComponent(1)] + self.pickerData[2][self.typePicker!.selectedRowInComponent(2)]
            var button: UIButton!
            button = buttonPreviews![2]
            button.setTitle(NSString(UTF8String: notename), forState: UIControlState.Normal)
            buttonPreviews![2].setTitle(notename, forState: UIControlState.Normal)
        } else {
            buttonPreviews![0].hidden = false
            buttonPreviews![1].hidden = false
            buttonPreviews![3].hidden = false
            buttonPreviews![4].hidden = false
        }
    }
    
    func updateLabel(){
        if (self.typePicker!.selectedRowInComponent(0) == 0) {
            pickerData = [
                ["Note", "Scale", "Chord"],
                ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
                ["1", "2", "3", "4", "5", "6", "7"],
                []
            ]
        } else if (self.typePicker!.selectedRowInComponent(0) > 0) {
            pickerData = [
                ["Note", "Scale", "Chord"],
                ["A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab"],
                ["1", "2", "3", "4", "5", "6", "7"],
                ["Blues", "Pentatonic", "Major"]
            ]
        }

        self.typePicker!.reloadAllComponents()
        self.typePicker!.selectRow(1, inComponent: 3, animated: true)

    }
    
}
