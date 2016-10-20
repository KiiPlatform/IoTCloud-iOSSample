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
    @IBOutlet weak var metadataField: UITextView!

    var delegate: TriggerOptionsViewControllerDelegate?

    var options: TriggerOptions?

    override func viewDidLoad() {
        if let options = self.options {
            self.titleField.text = options.title
            self.descriptionField.text = options.triggerDescription
            if let metadata = options.metadata {
                if let data = try? NSJSONSerialization.dataWithJSONObject(
                     metadata, options: .PrettyPrinted) {
                    self.metadataField.text =
                      NSString(data:data,
                               encoding:NSUTF8StringEncoding)! as String
                }
            }
        }
    }

    @IBAction func tapSaveCommand(sender: AnyObject) {
        var metadata: Dictionary<String, AnyObject>?
        if let text = self.metadataField.text {
            metadata = try? NSJSONSerialization.JSONObjectWithData(
              text.dataUsingEncoding(NSUTF8StringEncoding)!,
              options: .MutableContainers) as! Dictionary<String, AnyObject>
        } else {
            metadata = nil
        }

        self.delegate!.saveTriggerOptions(
          self.titleField.text,
          description: self.descriptionField.text,
          metadata: metadata)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
