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
    fileprivate var statePredicateToSave: StatePredicate?
    fileprivate var serverCodeToSave: ServerCode?
    fileprivate var options: TriggerOptions?

    override func viewWillAppear(_ animated: Bool) {
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTriggerServerCode" {
            if let destVC = segue.destination as? TriggerServerCodeEditViewController {
                if self.serverCodeToSave == nil {
                    destVC.serverCode = ServerCode(endpoint: "", executorAccessToken: "", targetAppID: "", parameters: nil)
                }else {
                    destVC.serverCode = serverCodeToSave
                }
                destVC.delegate = self
            }
        }else if segue.identifier == "editTriggerPredicate" {
            if let destVC = segue.destination as? StatesPredicateViewController {
                if self.statePredicateToSave == nil {
                    destVC.statePredicate = self.trigger?.predicate as? StatePredicate
                }else {
                    destVC.statePredicate = statePredicateToSave
                }
                destVC.delegate = self
            }
        } else if segue.identifier == "editTriggerOptions" {
            if let destVC = segue.destination
                    as? TriggerOptionsViewController {
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

    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveServerCode(_ newServerCode: ServerCode) {
        self.serverCodeToSave = newServerCode
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

    @IBAction func tapSaveTrigger(_ sender: AnyObject) {
        self.saveTrigger()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func saveTrigger() {
        if iotAPI != nil && target != nil && serverCodeToSave != nil && statePredicateToSave != nil {
            if trigger == nil {
                iotAPI!.postNewTrigger(
                  serverCodeToSave!,
                  predicate: statePredicateToSave!,
                  options: self.options,
                  completionHandler: { (newTrigger, error) -> Void in
                    if newTrigger != nil {
                        self.trigger = newTrigger
                        self.serverCodeToSave = newTrigger!.serverCode
                        self.statePredicateToSave = newTrigger?.predicate as? StatePredicate
                    }else {
                        self.showAlert("Create Trigger Failed", error: error, completion: nil)
                    }
                })
            } else {
                iotAPI!.patchTrigger(
                  trigger!.triggerID,
                  serverCode: serverCodeToSave!,
                  predicate: statePredicateToSave!,
                  options: self.options,
                  completionHandler: { (newTrigger, error) -> Void in
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
