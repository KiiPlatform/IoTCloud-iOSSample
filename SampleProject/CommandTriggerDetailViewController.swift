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

class CommandTriggerDetailViewController: KiiBaseTableViewController, TriggerCommandEditViewControllerDelegate, StatesPredicateViewControllerDelegate, TriggerOptionsViewControllerDelegate {

    @IBOutlet weak var commandDetailLabel: UILabel!

    @IBOutlet weak var statePredicateDetailLabel: UILabel!

    var trigger: Trigger?

    private var statePredicateToSave: StatePredicate?
    private var commandStructToSave: CommandStruct?
    private var options: TriggerOptions?

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
        } else if segue.identifier == "editTriggerOptions" {
            if let destVC = segue.destinationViewController as? TriggerOptionsViewController {
                if let options = self.options {
                    destVC.options = options
                } else if let trigger = self.trigger {
                    destVC.options = TriggerOptions(
                      title: trigger.title,
                      triggerDescription: trigger.triggerDescription,
                      metadata: trigger.metadata)
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
            if trigger != nil {
                iotAPI!.patchTrigger(
                  trigger!.triggerID,
                  triggeredCommandForm: TriggeredCommandForm(
                    schemaName: commandStructToSave!.schemaName,
                    schemaVersion: commandStructToSave!.schemaVersion,
                    actions: commandStructToSave!.actions),
                  predicate: statePredicateToSave,
                  options: self.options,
                  completionHandler: { (updatedTrigger, error) -> Void in
                    if updatedTrigger != nil {
                        self.trigger = updatedTrigger
                    }else {
                        self.showAlert("Update Trigger Failed", error: error, completion: nil)
                    }
                })
            }else {
                if statePredicateToSave != nil {
                    iotAPI!.postNewTrigger(
                      TriggeredCommandForm(
                        schemaName: commandStructToSave!.schemaName,
                        schemaVersion: commandStructToSave!.schemaVersion,
                        actions: commandStructToSave!.actions),
                      predicate: statePredicateToSave!,
                      options: self.options,
                      completionHandler: { (newTrigger, error) -> Void in
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

    func saveTriggerOptions(title: String?,
                            description: String?,
                            metadata: Dictionary<String, AnyObject>?)
    {
        if title != nil || description != nil || metadata != nil {
            self.options = TriggerOptions(title: title,
                                          triggerDescription: description,
                                          metadata: metadata)
        }
    }
}
