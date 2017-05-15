//
//  CommandNewViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/27/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class CommandNewViewController: CommandEditViewController {

    @IBOutlet weak var uploadButton: UIBarButtonItem!

    //MARK: IBActions methods
    @IBAction func tapUpload(_ sender: AnyObject) {

        if iotAPI != nil && target != nil && schema != nil{
            // disable upload button while uploading
            self.uploadButton.isEnabled = false

            // generate actions array
            var actions = [AliasAction]()
            if let actionsItems = sections[0].items {
                for actionItem in actionsItems {
                    if let actionCellData = actionItem as? ActionStruct {
                        actions.append(AliasAction(
                            AppConstants.DEFAULT_ALIAS,
                            actions: [Action(actionCellData.actionName, value: actionCellData.value)]))
                    }
                }
            }
            let form = CommandForm(actions)
            // call postNewCommand method
            iotAPI!.postNewCommand(form, completionHandler: { (command, error) -> Void in
                if command != nil {
                    self.navigationController!.popViewController(animated: true)
                }else {
                    self.showAlert("Upload Command Failed", error: error, completion: { () -> Void in
                        self.uploadButton.isEnabled = true
                    })
                }
            })
        }
    }


}
