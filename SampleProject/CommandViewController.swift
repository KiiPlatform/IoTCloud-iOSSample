//
//  CommandViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/25/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

extension CommandState {
    public func toString() -> String {
        switch self {
        case .delivered:
            return "DELIVERED"
        case .done:
            return "DONE"
        case .incomplete:
            return "INCOMPLETE"
        case .sending:
            return "SENDING"
        }
    }
}
class CommandViewController: KiiBaseTableViewController {
    struct SectionStruct {
        let headerTitle: String!
        var items: [Any]!
    }

    var command: Command?
    fileprivate var sections = [SectionStruct]()

    @IBAction func refreshCommand(_ sender: AnyObject) {
        if command != nil && iotAPI != nil && target != nil {
            iotAPI!.getCommand(command!.commandID, completionHandler: { (newCommand, error) -> Void in
                if newCommand != nil {
                    self.command = newCommand
                    self.loadSections()
                    self.tableView.reloadData()
                }else{
                    self.showAlert("Refresh Command Failed", error: error, completion: nil)
                }
            })
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if command != nil {
            self.navigationItem.title = command!.commandID
        }
        loadSections()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            return sections[section].items.count
        }else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count {
            return sections[section].headerTitle
        }else {
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if sections[indexPath.section].headerTitle == "Actions"  || sections[indexPath.section].headerTitle == "ActionResults" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionItemCell", for: indexPath)
            let action = sections[indexPath.section].items[indexPath.row] as! Dictionary<String, Any>
            if action.keys.count > 0 {
                let actionKey: String = (Array(action.keys) as! [String])[0]
                cell.textLabel?.text = actionKey
                var actionString = ""
                if let actionDict = action[actionKey] as? Dictionary<String, Any> {
                    for (key, value) in actionDict {
                        actionString = "\(key): \(value) "
                    }
                }
                cell.detailTextLabel?.text = actionString
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommandItemCell", for: indexPath)
            let item = sections[indexPath.section].items[indexPath.row]
            cell.textLabel?.text = "\(item)"
            return cell
        }
    }

    func loadSections() {
        sections.removeAll()
        if command != nil {
            sections.append(SectionStruct(headerTitle: "Schema", items: [command!.schemaName]))
            sections.append(SectionStruct(headerTitle: "Version", items: [command!.schemaVersion]))
            sections.append(SectionStruct(headerTitle: "Actions", items: command!.actions))
            sections.append(SectionStruct(headerTitle: "ActionResults", items: command!.actionResults))
            sections.append(SectionStruct(headerTitle: "State", items: [command!.commandState.toString()]))
        }else {
            sections.append(SectionStruct(headerTitle: "Schema", items: [schema!.name]))
            sections.append(SectionStruct(headerTitle: "Version", items: [schema!.version]))
            sections.append(SectionStruct(headerTitle: "Actions", items: [Any]()))
            sections.append(SectionStruct(headerTitle: "ActionResults", items: [Any]()))
            sections.append(SectionStruct(headerTitle: "State", items: [Any]()))
        }

    }

}
