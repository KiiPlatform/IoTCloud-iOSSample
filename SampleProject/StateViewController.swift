//
//  StateViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/25/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
class StateViewController: KiiBaseTableViewController {
    var stateStringsArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getState()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stateStringsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)

        cell.textLabel?.text = stateStringsArray[indexPath.row]

        return cell
    }

    func getState() {
        if target != nil && iotAPI != nil {
            showActivityView(true)
            iotAPI!.getState({ (statesDict, error) -> Void in
                self.showActivityView(false)
                if statesDict != nil {
                    self.stateStringsArray.removeAll()
                    for(key, value) in statesDict! {
                        self.stateStringsArray.append("\(key): \(value)")
                    }
                    self.tableView.reloadData()
                }
            })
        }
    }

    @IBAction func tapRefresh(_ sender: AnyObject) {
        getState()
    }
    @IBAction func tapLogout(_ sender: AnyObject) {
        logout { () -> Void in
            self.tabBarController?.viewDidAppear(true)
        }
    }
}
