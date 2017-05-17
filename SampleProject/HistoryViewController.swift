//
//  HistoryViewController.swift
//  SampleProject
//
//  Copyright (c) 2017 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class HistoryViewController: KiiBaseTableViewController {

    var resultsArray = [HistoryState]()
    var query: HistoryStatesQuery = HistoryStatesQuery(AppConstants.DEFAULT_ALIAS, clause: AllClause())

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getState()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)

        cell.textLabel?.text = "\(resultsArray[indexPath.row].createdAt)"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do {
            let title = "\(resultsArray[indexPath.row].createdAt)"
            let date = try JSONSerialization.data(withJSONObject: resultsArray[indexPath.row].state, options: [])
            let message = String(data: date, encoding: String.Encoding.utf8)
            showAlert(title, message: message, completion: nil)
        } catch (_) { }
    }

    func getState() {
        if target != nil && iotAPI != nil {
            showActivityView(true)

            iotAPI!.query(query) { (results, key, error) -> Void in
                self.showActivityView(false)
                if results != nil {
                    self.resultsArray.removeAll()
                    self.resultsArray += results!
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
