//
//  ServerCodeTriggerDetailViewController.swift
//  SampleProject
//
//  Created by 福崎範佳 on 2016/02/26.
//  Copyright © 2016年 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class ServerCodeTriggerDetailViewController: KiiBaseTableViewController, TriggerServerCodeEditViewControllerDelegate, StatesPredicateViewControllerDelegate {

    @IBOutlet weak var serverCodeDetailLabel: UILabel!
    @IBOutlet weak var statePredicateDetailLabel: UILabel!
    
    var trigger: Trigger?
    private var statePredicateToSave: StatePredicate?
    private var serverCodeToSave: ServerCode?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if trigger != nil {
            self.navigationItem.title = trigger!.triggerID
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
            statePredicateDetailLabel.text = statePredicateToSave!.triggersWhen.toString()
        }else {
            if let statePredicate = trigger?.predicate as? StatePredicate {
                statePredicateDetailLabel.text = statePredicate.triggersWhen.toString()
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
        }
    }

    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveServerCode(newServerCode: ServerCode) {
        self.serverCodeToSave = newServerCode
    }
    
    func saveStatePredicate(newPredicate: StatePredicate) {
        self.statePredicateToSave = newPredicate
    }

}
