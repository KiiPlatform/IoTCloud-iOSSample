//
//  OnBoardViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/24/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class OnBoardViewController: KiiBaseTableViewController {

    @IBOutlet weak var thingTypeTextField: UITextField!
    @IBOutlet weak var vendorThingID: UITextField!
    @IBOutlet weak var thingPassTextField: UITextField!
    @IBOutlet weak var thingIDTextField: UITextField!


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func tapOnboardWithVendorThingID(_ sender: AnyObject) {
        if let vendorThingID = vendorThingID.text, let thingPassword = thingPassTextField.text {
            showActivityView(true)
            let options = OnboardWithVendorThingIDOptions(thingType: thingTypeTextField.text)
            self.iotAPI?.onboardWith(vendorThingID: vendorThingID, thingPassword: thingPassword, options: options, completionHandler: { (target, error) -> Void in
                if target != nil {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.showActivityView(false)
                }else {
                    self.showAlert("Onboard Failed", error: error, completion: { () -> Void in
                        self.showActivityView(false)
                    })
                }
            })
        }
    }
    @IBAction func tapOnBoardWithThingID(_ sender: AnyObject) {
        if let thingID = thingIDTextField.text, let thingPassword = thingPassTextField.text {
            showActivityView(true)
            self.iotAPI?.onboardWith(thingID: thingID, thingPassword: thingPassword, completionHandler: { (target, error) -> Void in
                if target != nil {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    self.showActivityView(false)
                }else {
                    self.showAlert("Onboard Failed", error: error, completion: { () -> Void in
                        self.showActivityView(false)
                    })
                }
            })
        }
    }
}
