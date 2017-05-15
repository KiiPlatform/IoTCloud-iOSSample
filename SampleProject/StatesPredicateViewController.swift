//
//  StatesPredicateViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/27/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

protocol StatesPredicateViewControllerDelegate {

    func saveStatePredicate(_ newPredicate: StatePredicate)
}

class StatesPredicateViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate, StatusTableViewCellDelegate, IntervalStatusCellDelegate, AndOrClauseViewControllerDelegate {

    struct SectionStruct {
        let headerTitle: String
        var items: [Any]
        var clauses: [TriggerClause]
    }

    var statePredicate: StatePredicate?
    var delegate: StatesPredicateViewControllerDelegate?

    fileprivate var sections = [SectionStruct]()

    fileprivate var statusToSelect = [String]()
    fileprivate var clauseTypeToSelect = [ClauseType]()
    fileprivate var triggersWhensToSelect = [TriggersWhen.conditionChanged, TriggersWhen.conditionFalseToTrue, TriggersWhen.conditionTrue]

    fileprivate var triggersWhenSelected: TriggersWhen! {
        get {
            var triggersWhen: TriggersWhen?
            if sections[0].items.count > 0 {
                triggersWhen = sections[0].items[0] as? TriggersWhen
            }
            return triggersWhen
        }

        set {
                sections[0].items = [newValue]
            }
    }
    fileprivate var triggersWhenTempSelected: TriggersWhen? // it is setted each time when user select item from pickerView, as soon as tapping "set" button of pickerview, it will be assigned to triggersWhenSelected

    fileprivate var clauseSelected: TriggerClause! {
        get {
            var clause: TriggerClause?
            if sections[1].clauses.count > 0 {
                clause = sections[1].clauses[0]
            }
            return clause
        }
        set {
            sections[1].clauses = [newValue]
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

        if self.statePredicate == nil {
            sections.append(SectionStruct(headerTitle: "TriggersWhen", items: [triggersWhensToSelect[0]], clauses: [TriggerClause]()))
            sections.append(SectionStruct(headerTitle: "Condition", items: [Any](), clauses: [TriggerClause]()))
            triggersWhenSelected = triggersWhensToSelect[0]

        }else {
            sections.append(SectionStruct(headerTitle: "TriggersWhen", items: [statePredicate!.triggersWhen.rawValue], clauses: [TriggerClause]()))
            sections.append(SectionStruct(headerTitle: "Condition", items: [Any](), clauses: [statePredicate!.condition.clause]))
            triggersWhenSelected = statePredicate!.triggersWhen
            clauseSelected = self.statePredicate!.condition.clause
        }
    }

    //MARK: - TableView methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sections.count {
            if sections[section].headerTitle == "Condition" {// always is 1, if there is no clause, will show "Add Clause" button
                return 1
            }else {
                return sections[section].items.count
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
        if sections[indexPath.section].headerTitle == "Condition" {
            if sections[indexPath.section].clauses.count > 0 {
                if let clause = sections[indexPath.section].clauses[indexPath.row] as? RangeClauseInTrigger {
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

        if section.headerTitle == "Condition" {

            if section.clauses.count == 0 {
                 return tableView.dequeueReusableCell(withIdentifier: "NewClauseButtonCell", for: indexPath)
            }else {
                let clause = section.clauses[0]
                let clauseType = ClauseType.getClauseType(clause)!

                var cell: UITableViewCell!

                if clause is AndClauseInTrigger || clause is OrClauseInTrigger {
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
                        singleValue = (clause as! EqualsClauseInTrigger).value
                    case .NotEquals:
                        singleValue = (clause as! NotEqualsClauseInTrigger).equals.value
                    case .LessThanOrEquals, .LessThan:
                        singleValue = (clause as! RangeClauseInTrigger).upperLimit

                    case .GreaterThan, .GreaterThanOrEquals:
                        singleValue = (clause as! RangeClauseInTrigger).lowerLimit

                    case .LeftOpen, .RightOpen, .BothOpen, .BothClose:
                        let range = clause as! RangeClauseInTrigger
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
        }else {
            if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TriggersWhenCell", for: indexPath)
            let itemValue = sections[indexPath.section].items[indexPath.row]
            cell.textLabel?.text = "\(itemValue)"
            return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TriggersWhenPickerCell", for: indexPath)
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionStruct = sections[indexPath.section]

        if sectionStruct.headerTitle == "TriggersWhen" {
            self.showPickerView("TriggersWhen")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if sections[indexPath.section].headerTitle == "Condition" {
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
            if sections[indexPath.section].headerTitle == "Condition" {
                sections[indexPath.section].clauses.remove(at: indexPath.row)
            } else {
                sections[indexPath.section].items.remove(at: indexPath.row)
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

        if sentBy == "TriggersWhen"{
            picker.tag = 1
            if let selectedIndex = self.triggersWhensToSelect.index(of: triggersWhenSelected) {
                picker.selectRow(selectedIndex+1, inComponent: 0, animated: false)
            }
        }else{
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
        buttonCancel.addTarget(self, action: #selector(StatesPredicateViewController.cancelPicker(_:)), for: UIControlEvents.touchDown)


        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView

        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState())
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonOk) //add to the subview

        if sentBy == "TriggersWhen" {
            buttonOk.addTarget(self, action: #selector(StatesPredicateViewController.selectTriggersWhen(_:)), for: UIControlEvents.touchDown)
        }else {
            buttonOk.addTarget(self, action: #selector(StatesPredicateViewController.selectClauseAndStatus(_:)), for: UIControlEvents.touchDown)
        }


        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)

        self.present(alertController, animated: true, completion: nil)

    }

    //MARK: Custom methods
    func selectTriggersWhen(_ sender: UIButton){
        if triggersWhenTempSelected != nil {
            triggersWhenSelected = triggersWhenTempSelected
            self.tableView.reloadData()
        }
        self.dismiss(animated: true, completion: nil);
    }

    func selectClauseAndStatus(_ sender: UIButton) {
        if let clauseTypeSelected = clauseTypeTempSelected {
            if clauseTypeSelected == ClauseType.And {
                clauseSelected = AndClauseInTrigger()
            }else if clauseTypeSelected == ClauseType.Or {
                clauseSelected = OrClauseInTrigger()
            }

            if let statusSelected = statusTempSelected {
                if let initializedClaue = ClauseHelper.getInitializedClause(
                        AppConstants.DEFAULT_ALIAS,
                        clauseType: clauseTypeSelected,
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
        if pickerView.tag == 1 {
            return self.triggersWhensToSelect.count+1
        }else {
            if component == 0{
                return self.clauseTypeToSelect.count+1
            }else {
                return self.statusToSelect.count+1
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        }else {
            if pickerView.tag == 1{
                return self.triggersWhensToSelect[row-1].rawValue
            }else {
                if component == 0 {
                 return self.clauseTypeToSelect[row-1].rawValue
                }else {
                    return self.statusToSelect[row-1]
                }
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            if pickerView.tag == 1 {
                self.triggersWhenTempSelected = triggersWhensToSelect[row-1]
            }else {
                if component == 0 {
                    self.clauseTypeTempSelected = clauseTypeToSelect[row-1]
                }else {
                    self.statusTempSelected = statusToSelect[row-1]
                }
            }
        }
    }

    //MARK: IBActions methods
    @IBAction func tapSave(_ sender: AnyObject) {
        if self.delegate != nil {
            if triggersWhenSelected != nil && clauseSelected != nil {
                delegate!.saveStatePredicate(StatePredicate(Condition(clauseSelected!), triggersWhen: triggersWhenSelected!))
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
            if let newClause = ClauseHelper.getNewClause(AppConstants.DEFAULT_ALIAS, clause: clause, singleValue: value, statusSchema: statusSchema) {
                section.clauses[indexPath.row] = newClause
                sections[indexPath.section] = section
            }
        }
    }

    func setIntervalStatus(_ sender: UITableViewCell, lowerLimitValue: AnyObject, upperLimitValue: AnyObject) {
        let indexPath = self.tableView.indexPath(for: sender)!
        var section = sections[indexPath.section]
        let clause = section.clauses[indexPath.row] as! RangeClauseInTrigger
        let status = ClauseHelper.getStatusFromClause(clause)
        if let statusSchema = schema?.getStatusSchema(status) {
            if let newClause = ClauseHelper.getNewClause(AppConstants.DEFAULT_ALIAS, clause: clause, lowerLimitValue: lowerLimitValue, upperLimitValue: upperLimitValue, statusSchema: statusSchema) {
                section.clauses[indexPath.row] = newClause
                sections[indexPath.section] = section
            }
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editAndOrClause" {
            if let destVC = segue.destination as? AndOrClauseViewController {
                let cell = sender as! UITableViewCell
                let selectedIndexPath = self.tableView.indexPath(for: cell)!
                let andOrClause = sections[1].clauses[selectedIndexPath.row]
                destVC.andOrClause = andOrClause
                destVC.delegate = self
            }
        }
    }

    func saveClause(_ newClause: TriggerClause) {
        var section = sections[1]
        section.clauses = [newClause]
        sections[1] = section
    }

}
