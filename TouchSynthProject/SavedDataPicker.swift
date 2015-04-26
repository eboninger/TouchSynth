//
//  SavedDataPicker.swift
//  TouchSynthProject
//
//  Created by Comp150 on 4/26/15.
//  Copyright (c) 2015 Comp150. All rights reserved.
//

import Foundation

import UIKit

class SavedDataPicker: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView?
    
    var data = ["Test1", "Test2"]
    
    var textCellIdentifier = "TextCell"
    
    override init(frame f: CGRect) {
        super.init(frame: f)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize(tableView: UITableView)
    {
        self.data = ["Test1", "Test2", "Test3", "Test4"]
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
        //if (cell == nil) {
        //    cell = NSBundle.mainBundle().loadNibNamed("Cell", owner: self, options: nil)[0] as? UITableViewCell
        //}
        let row = indexPath.row
        cell!.textLabel?.text = data[row]
        cell!.textLabel?.font = UIFont(name: "Helvetica-BoldOblique", size: 18)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        NSLog("SELECTED: \(data[row])")
    }
    
    
}