//
//  SavedRecordingsPicker.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/27/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class SavedRecordingsPicker: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var parentViewController: Sequencer?
    
    var tableView: UITableView?
    
    var recordings: [[recData.sample]]?
    var data: [String] = []
    var recordingsCount = 1
    
    var textCellIdentifier = "TextCell"
    
    override init(frame f: CGRect) {
        super.init(frame: f)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize(parentViewController: Sequencer, tableView: UITableView, recordings: [[recData.sample]])
    {
        self.parentViewController = parentViewController
        self.recordings = recordings
        self.tableView = tableView
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as? UITableViewCell
        let row = indexPath.row
        cell!.textLabel?.text = data[indexPath.row]
        cell!.textLabel?.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        parentViewController!.recording = parentViewController!.recordings![row]
        parentViewController!.parentViewController!.curRecordingLabel.text = self.tableView?.cellForRowAtIndexPath(indexPath)!.textLabel!.text
        parentViewController!.savedRecordingsPicker!.hidden = true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.data.removeAtIndex(indexPath.row)
            parentViewController!.recordings!.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    func appendRecording() {
        var newRecordingLabel = "Recording \(recordingsCount++)"
        self.data.append(newRecordingLabel)
        self.tableView!.reloadData()
        parentViewController!.parentViewController!.curRecordingLabel.text = newRecordingLabel
    }
    
    
}
