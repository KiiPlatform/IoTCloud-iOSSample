//
//  TriggerCommandEditViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/27/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol TriggerCommandEditViewControllerDelegate {
    func saveCommands(_ schemaName: String,
                      schemaVersion: Int,
                      actions: [Dictionary<String, Any>],
                      targetID: String?,
                      title: String?,
                      commandDescription: String?,
                      metadata: Dictionary<String, Any>?)
}

class TriggerCommandEditViewController: CommandEditViewController {

    var delegate: TriggerCommandEditViewControllerDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        var targetIdSection = SectionStruct(headerTitle: "Target thing ID",
                                            items: [])
        var titleSection = SectionStruct(headerTitle: "Title", items: [])
        var descriptionSection = SectionStruct(headerTitle: "Description",
                                               items: [])
        var metadataSection = SectionStruct(headerTitle: "Meta data",
                                            items: [])

        if let command = self.commandStruct {
            if let targetID = command.targetID {
                targetIdSection.items.append(targetID)
            }
            if let title = command.title {
                titleSection.items.append(title)
            }
            if let description = command.commandDescription {
                descriptionSection.items.append(description)
            }
            if let metadata = command.metadata {
                if let data = try? JSONSerialization.data(
                     withJSONObject: metadata, options: .prettyPrinted) {
                    metadataSection.items.append(
                      String(data:data,
                             encoding:String.Encoding.utf8)!)
                }
            }
        }

        sections += [targetIdSection, titleSection, descriptionSection,
                     metadataSection]
    }

    override func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if sections[indexPath.section].headerTitle == "Target thing ID" {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: "TargetIDCell",
              for: indexPath)
            if let items = sections[indexPath.section].items, !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(202) as! UITextField).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Title" {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: "CommandTitleCell",
              for: indexPath)
            if let items = sections[indexPath.section].items, !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(203) as! UITextField).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Description" {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: "CommandDescriptionCell",
              for: indexPath)

            if let items = sections[indexPath.section].items, !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(204) as! UITextView).text = value
            }
            return cell
        } else if sections[indexPath.section].headerTitle == "Meta data" {
            let cell = tableView.dequeueReusableCell(
              withIdentifier: "CommandMetadataCell", for: indexPath)
            if let items = sections[indexPath.section].items, !items.isEmpty {
                let value = items[indexPath.row] as! String
                (cell.viewWithTag(205) as! UITextView).text = value
            }
            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(
      _ tableView: UITableView,
      heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if sections[indexPath.section].headerTitle == "Description" {
            return 130
        } else if sections[indexPath.section].headerTitle == "Meta data" {
            return 130
        } else {
            return super.tableView(tableView,
                                   heightForRowAt: indexPath)
        }
    }

    @IBAction func tapSaveCommand(_ sender: AnyObject) {
        // generate actions array
        var actions = [Dictionary<String, Any>]()
        if let actionsItems = sections[2].items {
            for actionItem in actionsItems {
                if let actionCellData = actionItem as? ActionStruct {
                    // action should be like: ["actionName": ["requiredStatus": value] ], where value can be Bool, Int or Double
                    actions.append(actionCellData.getActionDict())
                }
            }
        }
        // the defaultd schema and schemaVersion from predefined schem dict
        let schema: String? = (self.view.viewWithTag(200) as? UITextField)?.text
        let schemaVersion: Int?
        if let schemaVersionTextFiled = self.view.viewWithTag(201) as? UITextField {
            schemaVersion = Int(schemaVersionTextFiled.text!)!
        } else {
            schemaVersion = nil
        }
        let targetID: String?
        if let text = (self.view.viewWithTag(202) as? UITextField)?.text, !text.isEmpty {
            targetID = text
        } else {
            targetID = nil
        }
        let title: String?
        if let text = (self.view.viewWithTag(203) as? UITextField)?.text, !text.isEmpty {
            title = text
        } else {
            title = nil
        }
        let description: String?
        if let text = (self.view.viewWithTag(204) as? UITextView)?.text, !text.isEmpty {
            description = text
        } else {
            description = nil
        }
        let metadata: Dictionary<String, Any>?
        if let text = (self.view.viewWithTag(205) as? UITextView)?.text {
            metadata = try? JSONSerialization.jsonObject(
              with: text.data(using: String.Encoding.utf8)!,
              options: .mutableContainers) as! Dictionary<String, Any>
        } else {
            metadata = nil
        }

        if self.delegate != nil {
            delegate?.saveCommands(schema!,
                                   schemaVersion: schemaVersion!,
                                   actions: actions,
                                   targetID: targetID,
                                   title: title,
                                   commandDescription: description,
                                   metadata: metadata)
        }

        self.navigationController?.popViewController(animated: true)
    }

}
