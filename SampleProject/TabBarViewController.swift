//
//  TabBarViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/24/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class TabBarViewController: UITabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var savedIoTAPI: ThingIFAPI?

        // try to get iotAPI from NSUserDefaults
        do{
            try savedIoTAPI = ThingIFAPI.loadWithStoredInstance()
        }catch(_){
            // do nothing
        }

        // if there is not saved iotAPI, present login UIs
        if savedIoTAPI == nil {
            let storyBoard = UIStoryboard(name: "Onboarding", bundle: nil)
            let loginRootNaviVC = storyBoard.instantiateViewController(withIdentifier: "LoginRootViewController") as! UINavigationController
            self.present(loginRootNaviVC, animated: true, completion: nil)
        }
    }
}
