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
    
    var typePicker: UIPickerView?
    //var specsPicker: UIPickerView?
    var pickerData = [
        ["Note", "Scale", "Chord"],
        ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"],
        ["1", "2", "3", "4", "5", "6", "7"],
        ["Blues", "Pentatonic", "Major"]
    ]

    override init(frame f: CGRect) {
        super.init(frame: f)
    }
    
    // This should not be used
    required init(coder aDecoder: NSCoder) {
        println("Hello")
        super.init(coder: aDecoder)
    }
    
    func initialize(typePicker: UIPickerView)
    {
        self.typePicker = typePicker
        self.typePicker!.delegate = self
        self.typePicker!.dataSource = self
        self.typePicker!.selectRow(1, inComponent: 0, animated: true)
        self.typePicker!.selectRow(3, inComponent: 1, animated: true)
        self.typePicker!.selectRow(3, inComponent: 2, animated: true)
        self.typePicker!.selectRow(1, inComponent: 3, animated: true)

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
    }
    
    func updateLabel(){
        if (self.typePicker!.selectedRowInComponent(0) == 0) {
            pickerData = [
                ["Note", "Scale", "Chord"],
                ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"],
                ["1", "2", "3", "4", "5", "6", "7"],
                []
            ]
        } else if (self.typePicker!.selectedRowInComponent(0) > 0) {
            pickerData = [
                ["Note", "Scale", "Chord"],
                ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"],
                ["1", "2", "3", "4", "5", "6", "7"],
                ["Blues", "Pentatonic", "Major"]
            ]
        }

        self.typePicker!.reloadAllComponents()
        self.typePicker!.selectRow(1, inComponent: 3, animated: true)

    }
    
}
