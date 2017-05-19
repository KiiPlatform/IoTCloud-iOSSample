//
//  HistoryStateQueryEditViewController.swift
//  SampleProject
//
//  Copyright (c) 2017 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol HistoryStateQueryEditViewControllerDelegate {

    func saveHistoryStateQuery(_ newQuery: HistoryStatesQuery)
}

class HistoryStateQueryEditViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate, StatusTableViewCellDelegate, IntervalStatusCellDelegate, AndOrQueryClauseViewControllerDelegate {

    fileprivate let queryHeaderTitle = "Query Clause"

    struct SectionStruct {
        let headerTitle: String
        var clauses: [QueryClause]
    }

    var historyStateQuery: HistoryStatesQuery?
    var delegate: HistoryStateQueryEditViewControllerDelegate?

    fileprivate var sections = [SectionStruct]()

    fileprivate var statusToSelect = [String]()
    fileprivate var clauseTypeToSelect = [ClauseType]()
    fileprivate var clauseSelected: QueryClause! {
        get {
            let index = getIndex(queryHeaderTitle)
            var clause: QueryClause
            if sections[index].clauses.count > 0 {
                clause = sections[index].clauses[0]
            } else {
                clause = AllClause()
            }
            return clause
        }
        set {
            let index = getIndex(queryHeaderTitle)
            sections[index].clauses = [newValue]
        }
    }
    fileprivate var clauseTypeTempSelected: ClauseType?
    fileprivate var statusTempSelected: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // init actionSchemasToSelect from predefined schemaDict
        if schema != nil && statusToSelect.count == 0 {
            self.statusToSelect = schema!.getStatusNames()
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clauseTypeToSelect = ClauseType.getTypesArray()

        if self.historyStateQuery == nil {
            sections.append(SectionStruct(headerTitle: queryHeaderTitle, clauses: [QueryClause]()))
        }else {
            sections.append(SectionStruct(headerTitle: queryHeaderTitle, clauses: [historyStateQuery!.clause]))
            clauseSelected = self.historyStateQuery!.clause
        }
    }

    //MARK: - TableView methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            if sections[section].headerTitle == queryHeaderTitle {// always is 1, if there is no clause, will show "Add Clause" button
                return 1
            }else {
                return 0
            }
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].headerTitle == queryHeaderTitle {
            if sections[indexPath.section].clauses.count > 0 {
                if let clause = sections[indexPath.section].clauses[indexPath.row] as? RangeClauseInQuery {
                    if let clauseType = ClauseType.getClauseType(clause) {
                        if clauseType == ClauseType.LeftOpen || clauseType == ClauseType.RightOpen || clauseType == ClauseType.BothClose || clauseType == ClauseType.BothOpen {
                            return 100
                        }
                    }
                }
            }
            return 75
        }else {
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = sections[indexPath.section]

        if section.headerTitle == queryHeaderTitle {

            if section.clauses.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "NewClauseButtonCell", for: indexPath)
            }else {
                let clause = section.clauses[0]
                if clause is AllClause {
                    return tableView.dequeueReusableCell(withIdentifier: "NewClauseButtonCell", for: indexPath)
                }
                let clauseType = ClauseType.getClauseType(clause)!

                var cell: UITableViewCell!
                if clause is AndClauseInQuery || clause is OrClauseInQuery {
                    cell = tableView.dequeueReusableCell(withIdentifier: "AndOrClauseCell", for: indexPath)
                    cell.textLabel?.text = "\(clauseType.rawValue) Clause"
                }else {
                    // only for int and bool value
                    var singleValue: Any?
                    var lowerLimitValue: Int?
                    var upperLimitValue: Int?
                    let status = ClauseHelper.getStatusFromClause(clause)
                    let statusType = schema!.getStatusType(status)!

                    switch clauseType {
                    case .Equals:
                        singleValue = (clause as! EqualsClauseInQuery).value
                    case .NotEquals:
                        singleValue = (clause as! NotEqualsClauseInQuery).equals.value
                    case .LessThanOrEquals, .LessThan:
                        singleValue = (clause as! RangeClauseInQuery).upperLimit

                    case .GreaterThan, .GreaterThanOrEquals:
                        singleValue = (clause as! RangeClauseInQuery).lowerLimit

                    case .LeftOpen, .RightOpen, .BothOpen, .BothClose:
                        let range = clause as! RangeClauseInQuery
                        upperLimitValue = range.upperLimit as? Int
                        lowerLimitValue = range.lowerLimit as? Int

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
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "NewClauseButtonCell", for: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if sections[indexPath.section].headerTitle == queryHeaderTitle {
            if sections[indexPath.section].clauses.count == 0 {
                return false
            }else{
                return true
            }
        }else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == UITableViewCellEditingStyle.delete {
            if sections[indexPath.section].headerTitle == queryHeaderTitle {
                sections[indexPath.section].clauses.remove(at: indexPath.row)
            }
            self.tableView.reloadData()
        }
    }


    func showPickerView(_ sentBy: String) {

        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)

        if sentBy == "AddClause"{
            picker.tag = 2

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
        buttonCancel.addTarget(self, action: #selector(HistoryStateQueryEditViewController.cancelPicker(_:)), for: UIControlEvents.touchDown)


        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView

        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState())
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonOk) //add to the subview

        if sentBy == "AddClause" {
            buttonOk.addTarget(self, action: #selector(HistoryStateQueryEditViewController.selectClauseAndStatus(_:)), for: UIControlEvents.touchDown)
        }


        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)

        self.present(alertController, animated: true, completion: nil)

    }

    func selectClauseAndStatus(_ sender: UIButton) {
        if let clauseTypeSelected = clauseTypeTempSelected {
            if clauseTypeSelected == ClauseType.And {
                clauseSelected = AndClauseInQuery()
            }else if clauseTypeSelected == ClauseType.Or {
                clauseSelected = OrClauseInQuery()
            }

            if let statusSelected = statusTempSelected {
                if let initializedClaue = ClauseHelper.getInitializedClause(
                    clauseTypeSelected,
                    statusSchema: schema?.getStatusSchema(statusSelected)) {
                    clauseSelected = initializedClaue
                }
            }
            self.tableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil);
    }

    func cancelPicker(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil);
    }

    //MARK: Picker delegation methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return 1
        }else {
            return 2
        }
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
            if clauseSelected != nil {
                delegate!.saveHistoryStateQuery(HistoryStatesQuery(AppConstants.DEFAULT_ALIAS, clause: clauseSelected!))
            }
        }
        self.navigationController!.popViewController(animated: true)
    }

    @IBAction func tapAddClause(_ sender: AnyObject) {
        self.showPickerView("AddClause")
    }


    func setStatus(_ sender: UITableViewCell, value: Any) {
        let indexPath = self.tableView.indexPath(for: sender)!
        var section = sections[indexPath.section]
        let clause = section.clauses[indexPath.row]
        let status = ClauseHelper.getStatusFromClause(clause)
        if let statusSchema = schema?.getStatusSchema(status) {
            if let newClause = ClauseHelper.getNewClause(clause, singleValue: value, statusSchema: statusSchema) {
                section.clauses[indexPath.row] = newClause
                sections[indexPath.section] = section
            }
        }
    }

    func setIntervalStatus(_ sender: UITableViewCell, lowerLimitValue: AnyObject, upperLimitValue: AnyObject) {
        let indexPath = self.tableView.indexPath(for: sender)!
        var section = sections[indexPath.section]
        let clause = section.clauses[indexPath.row] as! RangeClauseInQuery
        let status = ClauseHelper.getStatusFromClause(clause)
        if let statusSchema = schema?.getStatusSchema(status) {
            if let newClause = ClauseHelper.getNewClause(clause, lowerLimitValue: lowerLimitValue, upperLimitValue: upperLimitValue, statusSchema: statusSchema) {
                section.clauses[indexPath.row] = newClause
                sections[indexPath.section] = section
            }
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAndOrClause" {
            if let destVC = segue.destination as? AndOrQueryClauseViewController {
                let cell = sender as! UITableViewCell
                let selectedIndexPath = self.tableView.indexPath(for: cell)!
                let queryIndex = getIndex(queryHeaderTitle)
                let andOrClause = sections[queryIndex].clauses[selectedIndexPath.row]
                destVC.andOrClause = andOrClause
                destVC.delegate = self
            }
        }
    }

    func saveClause(_ newClause: QueryClause) {
        let index = getIndex(queryHeaderTitle)
        var section = sections[index]
        section.clauses = [newClause]
        clauseSelected = section.clauses[0]
        sections[index] = section
    }

    fileprivate func getIndex(_ headerTitle: String) -> Int {
        for (index, section) in sections.enumerated() {
            if section.headerTitle == headerTitle {
                return index
            }
        }
        return -1
    }
}
