//
//  QueryViewController.swift
//  SampleProject
//
//  Copyright (c) 2017 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class QueryViewController: KiiBaseTableViewController {

    var resultStringsArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getState()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultStringsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)

        cell.textLabel?.text = resultStringsArray[indexPath.row]

        return cell
    }

    func getState() {
        if target != nil && iotAPI != nil {
            showActivityView(true)
            let query = HistoryStatesQuery(AppConstants.DEFAULT_ALIAS, clause: AllClause())

            iotAPI!.query(query) { (results, key, error) -> Void in
                self.showActivityView(false)
                if results != nil {
                    self.resultStringsArray.removeAll()
                    for result in results! {
                        self.resultStringsArray.append("\(result.createdAt): \(result.state)")
                    }
                    self.tableView.reloadData()
                }
            }
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
