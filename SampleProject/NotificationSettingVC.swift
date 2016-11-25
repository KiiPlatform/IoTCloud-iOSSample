//
//  NotificationSettingVC.swift
//  SampleProject
//
//  Created by Syah Riza on 8/27/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class NotificationSettingVC: UITableViewController {

    @IBOutlet weak var alertSwitch: UISwitch!
    @IBOutlet weak var installationSwitch: UISwitch!
    var savedIoTAPI: ThingIFAPI?
    override func viewDidLoad() {
        super.viewDidLoad()
        // try to get iotAPI from NSUserDefaults
        do{
            try savedIoTAPI = ThingIFAPI.loadWithStoredInstance()
        }catch(_){
            // do nothing
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        let userNotificationSettings = UIApplication.shared.currentUserNotificationSettings


        alertSwitch.isOn = userNotificationSettings!.types.contains(.alert)

        installationSwitch.isOn = self.savedIoTAPI?.installationID != nil
        kiiVerboseLog("Push Installation ID :",
                      self.savedIoTAPI?.installationID ?? "no installationID")
    }
    @IBAction func alertDidChange(_ sender: UISwitch) {

        if sender.isOn {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil))
        }else{

            let settings = UIUserNotificationSettings(types:UIUserNotificationType(), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }

    }
        @IBAction func didChangeInstallation(_ sender: UISwitch) {

        if sender.isOn {
            if let data = UserDefaults.standard.object(forKey: "deviceToken") as? Data {
                savedIoTAPI?.installPush(data, development: true, completionHandler: { (_, error) -> Void in
                    if error != nil {
                        self.installationSwitch.isOn = false
                    }
                })
            }
        }else{
            savedIoTAPI?.uninstallPush(nil, completionHandler: { (error) -> Void in
                if error != nil {
                    self.installationSwitch.isOn = true
                }
            })
        }
    }
}
