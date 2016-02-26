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

    
    
    //MARK: delegate function of TriggerCommandEditViewControllerDelegate, called when save command
    func saveCommands(serverCode: ServerCode) {
    }
    
    func saveStatePredicate(newPredicate: StatePredicate) {
    }

}
