//
//  ServerCodeTriggerDetailViewController.swift
//  SampleProject
//
//  Created by 福崎範佳 on 2016/02/26.
//  Copyright © 2016年 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class ServerCodeTriggerDetailViewController: KiiBaseTableViewController,
        TriggerServerCodeEditViewControllerDelegate,
        StatesPredicateViewControllerDelegate,
        TriggerOptionsViewControllerDelegate
{

    @IBOutlet weak var serverCodeDetailLabel: UILabel!
    @IBOutlet weak var statePredicateDetailLabel: UILabel!
    
    var trigger: Trigger?
    private var statePredicateToSave: StatePredicate?
    private var serverCodeToSave: ServerCode?
    private var options: TriggerOptions?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if trigger != nil {
            self.navigationItem.title = trigger!.triggerID
            serverCodeToSave = trigger!.serverCode
            statePredicateToSave = trigger!.predicate as? StatePredicate
        }else {
            self.navigationItem.title = "Create New Trigger"
        }
        
        if serverCodeToSave != nil {
            serverCodeDetailLabel.text = "\(serverCodeToSave!.endpoint)  \(serverCodeToSave!.executorAccessToken)"
        }else {
            if let serverCode = trigger?.serverCode {
                serverCodeDetailLabel.text = "\(serverCode.endpoint)  \(serverCode.executorAccessToken)"
            }else{
                serverCodeDetailLabel.text = " "
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTriggerServerCode" {
            if let destVC = segue.destinationViewController as? TriggerServerCodeEditViewController {
                if self.serverCodeToSave == nil {
                    destVC.serverCode = ServerCode(endpoint: "", executorAccessToken: "", targetAppID: "", parameters: nil)
                }else {
                    destVC.serverCode = serverCodeToSave
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
            if let destVC = segue.destinationViewController
                    as? TriggerOptionsViewController {
                if let trigger = self.trigger {
                    destVC.options = TriggerOptions(
                      title: trigger.title,
                      triggerDescription: trigger.triggerDescription,
                      metadata: trigger.metadata)
                } else if let options = self.options {
                    destVC.options = options
                }
                destVC.delegate = self
            }
        }
    }

    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveServerCode(newServerCode: ServerCode) {
        self.serverCodeToSave = newServerCode
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

    @IBAction func tapSaveTrigger(sender: AnyObject) {
        self.saveTrigger()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func saveTrigger() {
        if iotAPI != nil && target != nil && serverCodeToSave != nil && statePredicateToSave != nil {
            if trigger == nil {
                iotAPI!.postNewTrigger(serverCodeToSave!, predicate: statePredicateToSave!, completionHandler: { (newTrigger, error) -> Void in
                    if newTrigger != nil {
                        self.trigger = newTrigger
                        self.serverCodeToSave = newTrigger!.serverCode
                        self.statePredicateToSave = newTrigger?.predicate as? StatePredicate
                    }else {
                        self.showAlert("Create Trigger Failed", error: error, completion: nil)
                    }
                })
            } else {
                iotAPI!.patchTrigger(trigger!.triggerID, serverCode: serverCodeToSave!, predicate: statePredicateToSave!, completionHandler: { (newTrigger, error) -> Void in
                    if newTrigger != nil {
                        self.trigger = newTrigger
                        self.serverCodeToSave = newTrigger!.serverCode
                        self.statePredicateToSave = newTrigger?.predicate as? StatePredicate
                    }else {
                        self.showAlert("Update Trigger Failed", error: error, completion: nil)
                    }
                })
            }
        }
        
    }

}
