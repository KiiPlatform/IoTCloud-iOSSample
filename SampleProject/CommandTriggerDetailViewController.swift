//
//  TriggerDetailViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/26/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

struct CommandStruct {
    let schemaName: String!
    let schemaVersion: Int!
    let actions: [Dictionary<String, AnyObject>]!
}

class CommandTriggerDetailViewController: KiiBaseTableViewController, TriggerCommandEditViewControllerDelegate, StatesPredicateViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var commandDetailLabel: UILabel!

    @IBOutlet weak var statePredicateDetailLabel: UILabel!

    @IBOutlet weak var crossTriggerCell: UITableViewCell!
    @IBOutlet weak var thingIDCell: UITableViewCell!
    @IBOutlet weak var thingIDText: UITextField!
    @IBOutlet weak var vendorThingIDCell: UITableViewCell!
    @IBOutlet weak var vendorThingIDText: UITextField!

    enum TargetType: String {
        case NONE = "None"
        case STANDALONE = "StandaloneThing"
        case GATEWAY = "Gateway"
        case ENDNODE = "EndNode"
    }

    var trigger: Trigger?

    private var statePredicateToSave: StatePredicate?
    private var commandStructToSave: CommandStruct?
    private var commandTarget: Target?

    private let commandTargetList: [TargetType] = [.NONE, .STANDALONE, .GATEWAY, .ENDNODE]
    private var commandTargetSelected: TargetType = .NONE

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if trigger != nil {
            self.navigationItem.title = trigger!.triggerID
        }else {
            self.navigationItem.title = "Create New Trigger"
        }

        if commandStructToSave != nil {
            commandDetailLabel.text = "\(commandStructToSave!.schemaName):\(commandStructToSave!.schemaVersion), actions(\(commandStructToSave!.actions.count))"
        }else {
            if let command = trigger?.command {
                commandDetailLabel.text = "\(command.schemaName):\(command.schemaVersion), actions(\(command.actions.count))"
            }else{
                commandDetailLabel.text = " "
            }
        }

        if statePredicateToSave != nil {
            statePredicateDetailLabel.text = statePredicateToSave!.triggersWhen.rawValue
        }else {
            if let statePredicate = trigger?.predicate as? StatePredicate {
                statePredicateDetailLabel.text = statePredicate.triggersWhen.rawValue
            }else {
                statePredicateDetailLabel.text = " "
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if trigger != nil {
            commandStructToSave = CommandStruct(schemaName: self.trigger!.command!.schemaName, schemaVersion: self.trigger!.command!.schemaVersion, actions: self.trigger!.command!.actions)
        }
        // for UI.
        self.thingIDCell.hidden = true
        self.vendorThingIDCell.hidden = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTriggerCommand" {
            if let destVC = segue.destinationViewController as? TriggerCommandEditViewController {
                if self.commandStructToSave == nil {
                    if self.trigger != nil {
                    destVC.commandStruct = CommandStruct(schemaName: self.trigger!.command!.schemaName, schemaVersion: self.trigger!.command!.schemaVersion, actions: self.trigger!.command!.actions)
                    }
                }else {
                    destVC.commandStruct = commandStructToSave
                }
                destVC.delegate = self
            }

        }else if segue.identifier == "editTriggerPredicate" {
            if let destVC = segue.destinationViewController as? StatesPredicateViewController {
                if self.statePredicateToSave == nil {
                    destVC.statePredicate = self.trigger?.predicate as? StatePredicate
                }else {
                    destVC.statePredicate = statePredicateToSave
                }
                destVC.delegate = self
            }
        }
    }

    @IBAction func tapSaveTrigger(sender: AnyObject) {
        self.saveTrigger()
        self.navigationController?.popViewControllerAnimated(true)
    }
    func saveTrigger() {
        if iotAPI != nil && target != nil && commandStructToSave != nil {
            let thingID = thingIDText.text ?? ""
            let vendorThingID = vendorThingIDText.text ?? ""
            switch commandTargetSelected {
            case .STANDALONE:
                commandTarget = StandaloneThing(thingID: thingID, vendorThingID: vendorThingID)
                break
            case .GATEWAY:
                commandTarget = Gateway(thingID: thingID, vendorThingID: vendorThingID)
                break
            case .ENDNODE:
                commandTarget = EndNode(thingID: thingID, vendorThingID: vendorThingID)
                break
            default:
                commandTarget = nil
                break
            }
            if trigger != nil {
                iotAPI!.patchTrigger(trigger!.triggerID, schemaName: commandStructToSave!.schemaName, schemaVersion: commandStructToSave!.schemaVersion, commandTarget: commandTarget, actions: commandStructToSave!.actions, predicate: statePredicateToSave, completionHandler: { (updatedTrigger, error) -> Void in
                    if updatedTrigger != nil {
                        self.trigger = updatedTrigger
                    }else {
                        self.showAlert("Update Trigger Failed", error: error, completion: nil)
                    }
                })
            }else {
                if statePredicateToSave != nil {
                    iotAPI!.postNewTrigger(commandStructToSave!.schemaName, schemaVersion: commandStructToSave!.schemaVersion, actions: commandStructToSave!.actions, predicate: statePredicateToSave!, target: commandTarget, completionHandler: { (newTrigger, error) -> Void in
                        if newTrigger != nil {
                            self.trigger = newTrigger
                        }else {
                            self.showAlert("Create Trigger Failed", error: error, completion: nil)
                        }
                    })
                }
            }
        }

    }

    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveCommands(schemaName: String, schemaVersion: Int, actions: [Dictionary<String, AnyObject>]) {
        self.commandStructToSave = CommandStruct(schemaName: schemaName, schemaVersion: schemaVersion, actions: actions)
    }

    func saveStatePredicate(newPredicate: StatePredicate) {
        self.statePredicateToSave = newPredicate
    }

    //MARK: Picker delegation methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.commandTargetList.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.commandTargetList[row].rawValue
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = self.commandTargetList[row]
        if type == .NONE {
            self.thingIDCell.hidden = true
            self.vendorThingIDCell.hidden = true
        } else {
            self.thingIDCell.hidden = false
            self.vendorThingIDCell.hidden = false
        }
        self.commandTargetSelected = type
    }
}