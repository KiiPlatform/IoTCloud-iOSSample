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

    fileprivate let sections: NSArray = ["Command Triggers", "ServerCode Triggers"]
    var commandTriggers = [Trigger]()
    var serverCodeTriggers = [Trigger]()
    var nextSegue = "createCommandTrigger"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commandTriggers.removeAll()
        serverCodeTriggers.removeAll()
        
        self.tableView.reloadData()
        self.showActivityView(true)
        getTriggers(nil)
    }

    //MARK: Picker delegation methods
    func selectAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil);
        self.performSegue(withIdentifier: self.nextSegue, sender: self)
    }
    func cancelSelection(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil);
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Command Trigger"
        } else {
            return "ServerCode Trigger"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.nextSegue = "createCommandTrigger"
        } else {
            self.nextSegue = "createServerCodeTrigger"
        }
    }

    @IBAction func tapAddButton(_ sender: AnyObject) {
        
        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRect(x: 17, y: 5, width: 270, height: 45)
        let toolView: UIView = UIView(frame: toolFrame)
        
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState())
        buttonCancel.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonCancel) //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(TriggerListViewController.cancelSelection(_:)), for: UIControlEvents.touchDown)
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState())
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonOk) //add to the subview
        
        buttonOk.addTarget(self, action: #selector(TriggerListViewController.selectAction(_:)), for: UIControlEvents.touchDown)
        
        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Table view delegation methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return commandTriggers.count
        } else if section == 1 {
            return serverCodeTriggers.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "CommandTriggerCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CommandTriggerCell")
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ServerCodeTriggerCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ServerCodeTriggerCell")
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
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

        let enableAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: enableActionTitle, handler:{action, indexpath in
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

        enableAction.backgroundColor = UIColor.orange

        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in

            if self.iotAPI != nil && self.target != nil {
                // request to delete trigger
                self.iotAPI!.deleteTrigger( trigger.triggerID, completionHandler: { (trigger, error) -> Void in
                    if error == nil { // if delete trigger successfully in server, then delete it from table view
                        if indexPath.section == 0 {
                            self.commandTriggers.remove(at: indexPath.row)
                        } else {
                            self.serverCodeTriggers.remove(at: indexPath.row)
                        }
                        self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    }else{
                        self.showAlert("Delete Trigger Failed", error: error, completion: nil)
                    }
                })
            }
        });
        deleteRowAction.backgroundColor = UIColor.red
        
        let cell = tableView.cellForRow(at: indexPath)
        var showResultAction : UITableViewRowAction? = nil
        if indexPath.section == 1 {
            showResultAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Results", handler:{action, indexpath in
                self.performSegue(withIdentifier: "showServerCodeResults", sender: cell)
            });
            showResultAction!.backgroundColor = UIColor.green
        }
        if showResultAction == nil {
            return [deleteRowAction, enableAction]
        } else {
            return [deleteRowAction, enableAction, showResultAction!]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "showExistingCommandTriggerDetail", sender: cell)
        } else {
            self.performSegue(withIdentifier: "showExistingServerCodeTriggerDetail", sender: cell)
        }
    }
    
    //MARK: IBAction methods
    @IBAction func tapLogout(_ sender: AnyObject) {
        logout { () -> Void in
            self.tabBarController?.viewDidAppear(true)
        }
    }

    //MARK: Custom methods
    func getTriggers(_ nextPaginationKey: String?){
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExistingCommandTriggerDetail" {
            if let triggerDetailVC = segue.destination as? CommandTriggerDetailViewController {
                if let selectedCell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPath(for: selectedCell){
                        if indexPath.section == 0 {
                            triggerDetailVC.setup(
                              self.commandTriggers[indexPath.row]);
                        }
                    }
                }
            }
        } else if segue.identifier == "showExistingServerCodeTriggerDetail" {
            if let triggerDetailVC = segue.destination as? ServerCodeTriggerDetailViewController {
                if let selectedCell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPath(for: selectedCell){
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
        } else if segue.identifier == "showServerCodeResults" {
            if let serverCodeResultsVC = segue.destination as? TriggeredServerCodeResultViewController {
                if let selectedCell = sender as? UITableViewCell {
                    if let indexPath = self.tableView.indexPath(for: selectedCell){
                        serverCodeResultsVC.trigger = self.serverCodeTriggers[indexPath.row]
                    }
                }
            }
        }
    }
}
