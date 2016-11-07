//
//  AndOrClauseViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/28/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol AndOrClauseViewControllerDelegate {

    func saveClause(_ newClause: Clause)
}

class AndOrClauseViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, AndOrClauseViewControllerDelegate, StatusTableViewCellDelegate, IntervalStatusCellDelegate {

    var andOrClause: Clause!
    var delegate: AndOrClauseViewControllerDelegate?

    fileprivate var subClauses = [Clause]()

    // 2 columns of picker view
    fileprivate var statusToSelect = [String]()
    fileprivate var clauseTypeToSelect = [ClauseType]()

    // will be setted each time selecting items from picker
    fileprivate var clauseTypeTempSelected: ClauseType?
    fileprivate var statusTempSelected: String?

    // the And/OrClause in the list, which is clicked to next AndOrViewController
    fileprivate var subAndOrClauseSelected: IndexPath?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // init status list from predefined schema to select in picker view
        if schema != nil && statusToSelect.count == 0 {
            self.statusToSelect = schema!.getStatusNames()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // init clause type list from predefined schemaDict to select in picker view
        self.clauseTypeToSelect = ClauseType.getTypesArray()

        // init subClauses, the datas in table view
        if self.andOrClause != nil {
            if andOrClause is AndClause {
                let andClause = andOrClause as! AndClause
                subClauses = andClause.clauses
            }else {
                let orClause = andOrClause as! OrClause
                subClauses = orClause.clauses
            }
        }
    }

    //MARK: - TableView methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subClauses.count + 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < subClauses.count {
            if let clause = subClauses[indexPath.row] as? RangeClause {
                if let clauseType = ClauseType.getClauseType(clause) {
                    if clauseType == ClauseType.LeftOpen || clauseType == ClauseType.RightOpen || clauseType == ClauseType.BothClose || clauseType == ClauseType.BothOpen {
                        return 100
                    }
                }
            }
        }
        return 75
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == subClauses.count { // Cell for Add Clause
            return tableView.dequeueReusableCell(withIdentifier: "NewClauseButtonCell", for: indexPath)
        }else {
            let clause = subClauses[indexPath.row]
            let clauseDict = clause.toNSDictionary() as! [ String : Any ]
            let clauseType = ClauseType.getClauseType(clause)!

            var cell: UITableViewCell!

            if clause is AndClause || clause is OrClause {
                cell = tableView.dequeueReusableCell(withIdentifier: "AndOrClauseCell", for: indexPath)
                cell.textLabel?.text = "\(clauseType.rawValue) Clause"
            }else {
                let status = ClauseHelper.getStatusFromClause(clause)
                let statusType = schema!.getStatusType(status)!
                // only for int and bool value
                var singleValue: Any?
                var lowerLimitValue: Int?
                var upperLimitValue: Int?

                switch clauseType {
                case .Equals, .NotEquals:
                    if clauseType == ClauseType.Equals{
                        singleValue = clauseDict["value"]
                    }else {
                        singleValue = (clauseDict["clause"] as! Dictionary<String, AnyObject>)["value"]
                    }

                case .LessThanOrEquals, .LessThan:
                    singleValue = clauseDict["upperLimit"]

                case .GreaterThan, .GreaterThanOrEquals:
                    singleValue = clauseDict["lowerLimit"]

                case .LeftOpen, .RightOpen, .BothOpen, .BothClose:
                    upperLimitValue = clauseDict["upperLimit"] as? Int
                    lowerLimitValue = clauseDict["lowerLimit"] as? Int

                default:
                    break
                }

                switch statusType {
                case StatusType.BoolType:
                    let boolCell = tableView.dequeueReusableCell(withIdentifier: "BoolCell", for: indexPath) as! StatusBoolTypeTableViewCell
                    boolCell.value = singleValue as? Bool
                    boolCell.titleLabel.text = clauseType.rawValue
                    boolCell.statusNameLabel.text = status
                    boolCell.delegate = self
                    cell = boolCell

                case StatusType.IntType:

                    if singleValue != nil {
                        let intCell = tableView.dequeueReusableCell(withIdentifier: "IntCell", for: indexPath) as! StatusIntTypeTableViewCell
                        intCell.statusNameLabel.text = status
                        intCell.titleLabel.text = clauseType.rawValue
                        intCell.value = singleValue as? Int
                        intCell.minValue = schema?.getStatusSchema(status)?.minValue as? Int
                        intCell.maxValue = schema?.getStatusSchema(status)?.maxValue as? Int
                        intCell.delegate = self
                        cell = intCell

                    }
                    if lowerLimitValue != nil && upperLimitValue != nil {
                        let intervalCell = tableView.dequeueReusableCell(withIdentifier: "IntervalCell", for: indexPath) as! IntervalStatusIntTypeCell
                        intervalCell.titleLabel.text = clauseType.rawValue
                        intervalCell.upperLimitValue = upperLimitValue!
                        intervalCell.lowerLimitValue = lowerLimitValue!
                        intervalCell.minValue = schema?.getStatusSchema(status)?.minValue as? Int
                        intervalCell.maxValue = schema?.getStatusSchema(status)?.maxValue as? Int
                        intervalCell.delegate = self
                        cell = intervalCell
                    }

                default:
                    break
                }

            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < subClauses.count {
            let clauseSelected = subClauses[indexPath.row]
            if clauseSelected is AndClause || clauseSelected is OrClause{
                let storyBoard = UIStoryboard(name: "Triggers", bundle: nil)
                if let andOrVC = storyBoard.instantiateViewController(withIdentifier: "AndOrClauseViewController") as? AndOrClauseViewController {
                    andOrVC.andOrClause = clauseSelected
                    andOrVC.delegate = self
                    self.subAndOrClauseSelected = indexPath
                    self.navigationController?.pushViewController(andOrVC, animated: true)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == subClauses.count {
            return false
        }else {
            return true
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == UITableViewCellEditingStyle.delete {
            subClauses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }

    func showPickerView() {

        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)

        if let statusSelected = self.statusTempSelected {
            if let selectedIndex = self.statusToSelect.index(of: statusSelected) {
                picker.selectRow(selectedIndex+1, inComponent: 1, animated: false)
            }
        }

        if let clauseTypeSelected = self.clauseTypeTempSelected {
            if let selectedIndex = self.clauseTypeToSelect.index(of: clauseTypeSelected) {
                picker.selectRow(selectedIndex+1, inComponent: 0, animated: false)
            }
        }

        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRect(x: 17, y: 5, width: 270, height: 45)
        let toolView: UIView = UIView(frame: toolFrame)

        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRect(x: 0, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView

        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", for: UIControlState())
        buttonCancel.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonCancel) //add it to the toolView

        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(AndOrClauseViewController.cancelPicker(_:)), for: UIControlEvents.touchDown)


        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView

        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState())
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonOk) //add to the subview

        buttonOk.addTarget(self, action: #selector(AndOrClauseViewController.selectClauseAndStatus(_:)), for: UIControlEvents.touchDown)

        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)

        self.present(alertController, animated: true, completion: nil)

    }

    //MARK: Custom methods
    func selectClauseAndStatus(_ sender: UIButton) {
        if let clauseTypeSelected = clauseTypeTempSelected {
            var clauseSelected: Clause?
            if clauseTypeSelected == ClauseType.And {
                clauseSelected = AndClause()
            }else if clauseTypeSelected == ClauseType.Or {
                clauseSelected = OrClause()
            }
            if let statusSelected = statusTempSelected {
                if let initializedClaue = ClauseHelper.getInitializedClause(clauseTypeSelected, statusSchema: schema?.getStatusSchema(statusSelected)) {
                    clauseSelected = initializedClaue
                }
            }

            if clauseSelected != nil {
                self.subClauses.append(clauseSelected!)
                self.tableView.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil);
    }

    func cancelPicker(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil);
    }

    //MARK: Picker delegation methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if component == 0{
            return self.clauseTypeToSelect.count+1
        }else {
            return self.statusToSelect.count+1
        }

    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        }else {
            if component == 0 {
                return self.clauseTypeToSelect[row-1].rawValue
            }else {
                return self.statusToSelect[row-1]
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            if component == 0 {
                self.clauseTypeTempSelected = clauseTypeToSelect[row-1]
            }else {
                self.statusTempSelected = statusToSelect[row-1]
            }
        }
    }

    //MARK: IBActions methods
    @IBAction func tapSave(_ sender: AnyObject) {
        if self.delegate != nil {
            if andOrClause is AndClause {
                let newClause = AndClause()
                for subClause in subClauses {
                    newClause.add(subClause)
                }
                delegate!.saveClause(newClause)
            }else {
                let newClause = OrClause()
                for subClause in subClauses {
                    newClause.add(subClause)
                }
                delegate!.saveClause(newClause)
            }
        }
        self.navigationController!.popViewController(animated: true)
    }

    @IBAction func tapAddClause(_ sender: AnyObject) {
        self.showPickerView()
    }


    func saveClause(_ newClause: Clause) {
        if subAndOrClauseSelected != nil {
            subClauses[subAndOrClauseSelected!.row] = newClause
        }
    }

    func setStatus(_ sender: UITableViewCell, value: Any) {
        let indexPath = self.tableView.indexPath(for: sender)!
        let clause = subClauses[indexPath.row]
        let status = ClauseHelper.getStatusFromClause(clause)
        if let statusSchema = schema?.getStatusSchema(status) {
            if let newClause = ClauseHelper.getNewClause(clause, singleValue: value, statusSchema: statusSchema) {
                subClauses[indexPath.row] = newClause
            }
        }
    }

    func setIntervalStatus(_ sender: UITableViewCell, lowerLimitValue: AnyObject, upperLimitValue: AnyObject) {
        let indexPath = self.tableView.indexPath(for: sender)!
        let clause = subClauses[indexPath.row] as! RangeClause
        let status = ClauseHelper.getStatusFromClause(clause)
        if let statusSchema = schema?.getStatusSchema(status) {
            if let newClause = ClauseHelper.getNewClause(clause, lowerLimitValue: lowerLimitValue, upperLimitValue: upperLimitValue, statusSchema: statusSchema) {
                subClauses[indexPath.row] = newClause
            }
        }

    }

}
