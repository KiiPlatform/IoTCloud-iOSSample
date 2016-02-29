//
//  TriggerListViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/26/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class TriggerListViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var commandTriggers = [Trigger]()
    var serverCodeTriggers = [Trigger]()
    var nextSegue = "createCommandTrigger"

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        commandTriggers.removeAll()
        serverCodeTriggers.removeAll()
        
        self.tableView.reloadData()
        self.showActivityView(true)
        getTriggers(nil)
    }

    //MARK: Picker delegation methods
    func selectAction(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil);
        self.performSegueWithIdentifier(self.nextSegue, sender: self)
    }
    func cancelSelection(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Command Trigger"
        } else {
            return "ServerCode Trigger"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.nextSegue = "createCommandTrigger"
        } else {
            self.nextSegue = "createServerCodeTrigger"
        }
    }

    @IBAction func tapAddButton(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let pickerFrame = CGRectMake(17, 52, 270, 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRectMake(17, 5, 270, 45)
        let toolView: UIView = UIView(frame: toolFrame)
        
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRectMake(0, 7, 100, 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        toolView.addSubview(buttonCancel) //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: "cancelSelection:", forControlEvents: UIControlEvents.TouchDown)
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRectMake(170, 7, 100, 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", forState: UIControlState.Normal)
        buttonOk.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        toolView.addSubview(buttonOk) //add to the subview
        
        buttonOk.addTarget(self, action: "selectAction:", forControlEvents: UIControlEvents.TouchDown)
        
        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: Table view delegation methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return commandTriggers.count
        } else {
            return serverCodeTriggers.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("CommandTriggerCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CommandTriggerCell")
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("ServerCodeTriggerCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ServerCodeTriggerCell")
            }
        }

        var trigger: Trigger
        if indexPath.section == 0 {
            trigger = commandTriggers[indexPath.row]
        } else {
            trigger = serverCodeTriggers[indexPath.row]
        }
        
        cell!.textLabel?.text = trigger.triggerID
        if trigger.enabled {
            cell!.detailTextLabel?.text = "enabled"
        }else {
            cell!.detailTextLabel?.text = "disabled"
        }
        return cell!
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var enableActionTitle: String!
        var trigger: Trigger
        if indexPath.section == 0 {
            trigger = commandTriggers[indexPath.row]
        } else {
            trigger = serverCodeTriggers[indexPath.row]
        }
        if trigger.enabled {
            enableActionTitle = "Disable"
        }else {
            enableActionTitle = "Enable"
        }

        let enableAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: enableActionTitle, handler:{action, indexpath in
            if self.iotAPI != nil && self.target != nil {
                self.iotAPI!.enableTrigger(trigger.triggerID, enable: !trigger.enabled, completionHandler: { (trigger, error) -> Void in
                    if error == nil {
                        // update triggers array
                        if indexPath.section == 0 {
                            self.commandTriggers[indexPath.row] = trigger!
                        } else {
                            self.serverCodeTriggers[indexPath.row] = trigger!
                        }
                        self.tableView.reloadData()
                    }else {
                        self.showAlert("\(enableActionTitle) Trigger Failed", error: error, completion: nil)
                    }
                })
            }
        });

        enableAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);

        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in

            if self.iotAPI != nil && self.target != nil {
                // request to delete trigger
                self.iotAPI!.deleteTrigger( trigger.triggerID, completionHandler: { (trigger, error) -> Void in
                    if error == nil { // if delete trigger successfully in server, then delete it from table view
                        if indexPath.section == 0 {
                            self.commandTriggers.removeAtIndex(indexPath.row)
                        } else {
                            self.serverCodeTriggers.removeAtIndex(indexPath.row)
                        }
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    }else{
                        self.showAlert("Delete Trigger Failed", error: error, completion: nil)
                    }
                })
            }
        });
        return [deleteRowAction, enableAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("showExistingCommandTriggerDetail", sender: self)
        } else {
            self.performSegueWithIdentifier("showExistingServerCodeTriggerDetail", sender: self)
        }
    }
    
    //MARK: IBAction methods
    @IBAction func tapLogout(sender: AnyObject) {
        logout { () -> Void in
            self.tabBarController?.viewDidAppear(true)
        }
    }

    //MARK: Custom methods
    func getTriggers(nextPaginationKey: String?){
        if iotAPI != nil && target != nil {
            showActivityView(true)
            // use default bestEffortLimit
            iotAPI!.listTriggers(nil, paginationKey: nextPaginationKey, completionHandler: { (triggers, paginationKey, error) -> Void in
                self.showActivityView(false)
                if triggers != nil {
                    for trigger in triggers! {
                        if trigger.command != nil {
                            self.commandTriggers.append(trigger)
                        } else {
                            self.serverCodeTriggers.append(trigger)
                        }
                    }
                    // paginationKey is nil, then there is not more triggers, reload table
                    if paginationKey == nil {
                        self.tableView.reloadData()
                        self.showActivityView(false)
                    }else {
                        self.getTriggers(paginationKey)
                    }
                }else {
                    self.showAlert("Get Triggers Failed", error: error, completion: nil)
                }
            })
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showExistingCommandTriggerDetail" {
            if let triggerDetailVC = segue.destinationViewController as? CommandTriggerDetailViewController {
                if let selectedCell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(selectedCell){
                        var selectedTrigger: Trigger
                        if indexPath.section == 0 {
                            selectedTrigger = self.commandTriggers[indexPath.row]
                        } else {
                            selectedTrigger = self.serverCodeTriggers[indexPath.row]
                        }
                        triggerDetailVC.trigger = selectedTrigger
                    }
                }
            }
        } else if segue.identifier == "showExistingServerCodeTriggerDetail" {
            if let triggerDetailVC = segue.destinationViewController as? ServerCodeTriggerDetailViewController {
                if let selectedCell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPathForCell(selectedCell){
                        var selectedTrigger: Trigger
                        if indexPath.section == 0 {
                            selectedTrigger = self.commandTriggers[indexPath.row]
                        } else {
                            selectedTrigger = self.serverCodeTriggers[indexPath.row]
                        }
                        triggerDetailVC.trigger = selectedTrigger
                    }
                }
            }
        }
    }
}
