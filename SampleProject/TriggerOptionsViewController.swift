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
    func saveTriggerOptions(_ title: String?,
                            description: String?,
                            metadata: Dictionary<String, Any>?)
}

class TriggerOptionsViewController: KiiBaseTableViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var metadataField: UITextView!

    var delegate: TriggerOptionsViewControllerDelegate?

    var options: TriggerOptions?

    override func viewDidLoad() {
        if let options = self.options {
            self.titleField.text = options.title
            self.descriptionField.text = options.triggerDescription
            if let metadata = options.metadata {
                if let data = try? JSONSerialization.data(
                     withJSONObject: metadata, options: .prettyPrinted) {
                    self.metadataField.text =
                      NSString(data:data,
                               encoding:String.Encoding.utf8.rawValue)! as String
                }
            }
        }
    }

    @IBAction func tapSaveTriggerOptions(_ sender: AnyObject) {
        var metadata: Dictionary<String, Any>?
        if let text = self.metadataField.text {
            metadata = try? JSONSerialization.jsonObject(
              with: text.data(using: String.Encoding.utf8)!,
              options: .mutableContainers) as! Dictionary<String, Any>
        } else {
            metadata = nil
        }

        self.delegate!.saveTriggerOptions(
          self.titleField.text,
          description: self.descriptionField.text,
          metadata: metadata)
        _ = self.navigationController?.popViewController(animated: true)
    }
}
