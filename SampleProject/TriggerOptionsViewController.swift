//
//  TriggerOptionsViewController.swift
//  SampleProject
//
//  Created on 2016/10/14.
//  Copyright (c) 2016 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol TriggerOptionsViewControllerDelegate {
    func saveTriggerOptions(title: String?,
                            description: String?,
                            metadata: Dictionary<String, AnyObject>?)
}

class TriggerOptionsViewController: KiiBaseTableViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    // TODO: changeto IBOutlet.
    var metadata: Dictionary<String, AnyObject>?

    var delegate: TriggerOptionsViewControllerDelegate?

    var options: TriggerOptions?

    override func viewDidLoad() {
        if let options = self.options {
            self.titleField.text = options.title
            self.descriptionField.text = options.triggerDescription
        }
    }

    @IBAction func tapSaveCommand(sender: AnyObject) {
        self.delegate!.saveTriggerOptions(
          self.titleField.text,
          description:self.descriptionField.text,
          metadata:nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
