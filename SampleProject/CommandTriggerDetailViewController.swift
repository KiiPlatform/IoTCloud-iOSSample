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
    let actions: [Dictionary<String, Any>]!
    let targetID: String?
    let title: String?
    let commandDescription: String?
    let metadata: Dictionary<String, Any>?
}

class CommandTriggerDetailViewController: KiiBaseTableViewController, TriggerCommandEditViewControllerDelegate, StatesPredicateViewControllerDelegate, TriggerOptionsViewControllerDelegate {

    @IBOutlet weak var commandDetailLabel: UILabel!

    @IBOutlet weak var statePredicateDetailLabel: UILabel!

    fileprivate var triggerID: String?
    fileprivate var statePredicateToSave: StatePredicate?
    fileprivate var commandStructToSave: CommandStruct?
    fileprivate var options: TriggerOptions?

    func setup(_ trigger: Trigger) {
        self.triggerID = trigger.triggerID
        let command = trigger.command!
        self.commandStructToSave = CommandStruct(
          schemaName: command.schemaName,
          schemaVersion: command.schemaVersion,
          actions: command.actions,
          targetID: command.targetID.id,
          title: command.title,
          commandDescription: command.commandDescription,
          metadata: command.metadata)
        self.statePredicateToSave = trigger.predicate as? StatePredicate
        if trigger.title != nil ||
             trigger.triggerDescription != nil ||
             trigger.metadata != nil {
            self.options = TriggerOptions(
              title: trigger.title,
              triggerDescription: trigger.triggerDescription,
              metadata: trigger.metadata)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = self.triggerID ?? "Create New Trigger"

        if let command = self.commandStructToSave {
            commandDetailLabel.text = "\(command.schemaName):\(command.schemaVersion), actions(\(command.actions.count))"
        } else {
            commandDetailLabel.text = " "
        }

        self.statePredicateDetailLabel.text =
          self.statePredicateToSave?.triggersWhen.rawValue ?? " "
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTriggerCommand" {
            if let destVC = segue.destination as? TriggerCommandEditViewController {
                destVC.commandStruct = self.commandStructToSave
                destVC.delegate = self
            }

        }else if segue.identifier == "editTriggerPredicate" {
            if let destVC = segue.destination as? StatesPredicateViewController {
                destVC.statePredicate = self.statePredicateToSave
                destVC.delegate = self
            }
        } else if segue.identifier == "editTriggerOptions" {
            if let destVC = segue.destination as? TriggerOptionsViewController {
                destVC.options = self.options
                destVC.delegate = self
            }
        }
    }

    @IBAction func tapSaveTrigger(_ sender: AnyObject) {
        self.saveTrigger()
        self.navigationController?.popViewController(animated: true)
    }
    func saveTrigger() {
        if let api = iotAPI {
            let commandTargetID: TypedID?
            if let id = self.commandStructToSave?.targetID {
                commandTargetID = TypedID(type: "thing", id: id)
            } else {
                commandTargetID = nil
            }
            if let triggerID = self.triggerID {
                let command = self.commandStructToSave!
                let predicate = self.statePredicateToSave!
                api.patchTrigger(
                  triggerID,
                  triggeredCommandForm: TriggeredCommandForm(
                    schemaName: command.schemaName,
                    schemaVersion: command.schemaVersion,
                    actions: command.actions,
                    targetID: commandTargetID,
                    title: command.title,
                    commandDescription: command.commandDescription,
                    metadata: command.metadata),
                  predicate: predicate,
                  options: self.options,
                  completionHandler: { (updatedTrigger, error) -> Void in
                    if error != nil {
                        self.showAlert("Update Trigger Failed", error: error, completion: nil)
                    }
                })
            } else if let command = self.commandStructToSave,
                      let predicate = self.statePredicateToSave {
                api.postNewTrigger(
                  TriggeredCommandForm(
                    schemaName: command.schemaName,
                    schemaVersion: command.schemaVersion,
                    actions: command.actions,
                    targetID: commandTargetID,
                    title: command.title,
                    commandDescription: command.commandDescription,
                    metadata: command.metadata),
                  predicate: predicate,
                  options: self.options,
                  completionHandler: { (newTrigger, error) -> Void in
                      if error != nil {
                          self.showAlert("Create Trigger Failed", error: error, completion: nil)
                      }
                  })
            }
        }

    }

    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveCommands(
      _ schemaName: String,
      schemaVersion: Int,
      actions: [Dictionary<String, Any>],
      targetID: String?,
      title: String?,
      commandDescription: String?,
      metadata: Dictionary<String, Any>?) {
        self.commandStructToSave = CommandStruct(
          schemaName: schemaName,
          schemaVersion: schemaVersion,
          actions: actions,
          targetID: targetID,
          title: title,
          commandDescription: commandDescription,
          metadata: metadata)
    }

    func saveStatePredicate(_ newPredicate: StatePredicate) {
        self.statePredicateToSave = newPredicate
    }

    func saveTriggerOptions(_ title: String?,
                            description: String?,
                            metadata: Dictionary<String, Any>?)
    {
        if title != nil || description != nil || metadata != nil {
            self.options = TriggerOptions(title: title,
                                          triggerDescription: description,
                                          metadata: metadata)
        }
    }
}
