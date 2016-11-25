//
//  CommandsListViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/25/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

struct CommandsSection {
    let state: String!
    let commands: [Command]!
    init(state: CommandState, commands: [Command]) {
        self.commands = commands
        switch state {
        case .delivered:
            self.state = "DELIVERED"
        case .done:
            self.state = "DONE"
        case .incomplete:
            self.state = "INCOMPLETE"
        case .sending:
            self.state = "SENDING"
        }
    }
}
class CommandsListViewController: KiiBaseTableViewController {
    var sections = [CommandsSection]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCommands()

    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            return sections[section].commands.count
        }else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sections.count {
            return sections[section].state
        }else {
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommandCell", for: indexPath)

        let command = sections[indexPath.section].commands[indexPath.row]
        cell.textLabel?.text = command.commandID
        cell.detailTextLabel?.text = "\(command.schemaName):\(command.schemaVersion), actions(\(command.actions.count))"

        return cell

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommandViewController" {
            if let targetVC = segue.destination as? CommandViewController {
                if let selectedTableViewCell = sender as? UITableViewCell {
                    if let selectedIndexPath = self.tableView.indexPath(for: selectedTableViewCell) {
                        let selectedCommand = sections[selectedIndexPath.section].commands[selectedIndexPath.row]
                            targetVC.command = selectedCommand
                    }
                }
            }
        }
    }

    func getCommands(){
        if iotAPI != nil && target != nil {
            showActivityView(true)
            iotAPI!.listCommands(nil, paginationKey: nil, completionHandler: { (commands, nextPaginationKey, error) -> Void in
                self.showActivityView(false)
                if commands != nil {
                    var commandStateDict = Dictionary<CommandState, [Command]>()
                    for command in commands! {
                        if let commandsArray = commandStateDict[command.commandState]{
                            commandStateDict[command.commandState] = commandsArray+[command]
                        }else {
                            commandStateDict[command.commandState] = [command]
                        }
                    }
                    self.sections.removeAll()
                    for key in commandStateDict.keys {
                        self.sections.append(CommandsSection(state: key, commands: commandStateDict[key]!))
                    }
                    self.tableView.reloadData()
                }else {
                    self.showAlert("Get Commands Failed", error: error, completion: nil)
                }
            })
        }
    }
    @IBAction func tapLogout(_ sender: AnyObject) {
        self.logout { () -> Void in
            self.tabBarController?.viewDidAppear(true)
        }
    }
}
