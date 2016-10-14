//
//  TriggerOptionsViewController.swift
//  SampleProject
//
//  Created on 2016/10/14.
//  Copyright (c) 2016 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class TriggerOptionsViewController: KiiBaseTableViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!

    @IBAction func tapSaveCommand(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
