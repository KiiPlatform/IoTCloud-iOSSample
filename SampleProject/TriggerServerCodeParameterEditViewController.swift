import UIKit
import ThingIFSDK

protocol TriggerServerCodeParameterEditViewControllerDelegate {
    func saveParameter(parameters: [ParameterStruct])
}

class TriggerServerCodeParameterEditViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var parameters: [ParameterStruct] = []
    var delegate: TriggerServerCodeParameterEditViewControllerDelegate?
    
    @IBAction func tapNewParameter(sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let pickerFrame = CGRectMake(17, 52, 270, 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRectMake(17, 5, 270, 45)
        let toolView: UIView = UIView(frame: toolFrame)
        
        //add buttons to the view
        let buttonCancelFrame: CGRect = CGRectMake(0, 7, 100, 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame)
        buttonCancel.setTitle("Cancel", forState: UIControlState.Normal)
        buttonCancel.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        toolView.addSubview(buttonCancel) //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: "cancelSelection:", forControlEvents: UIControlEvents.TouchDown)
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRectMake(170, 7, 100, 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", forState: UIControlState.Normal)
        buttonOk.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        toolView.addSubview(buttonOk) //add to the subview
        
        buttonOk.addTarget(self, action: #selector(TriggerServerCodeParameterEditViewController.selectAction(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapSaveParameter(sender: AnyObject) {
        
        for rowIndex in 0...self.tableView.numberOfRowsInSection(0) {
            let indexPath : NSIndexPath = NSIndexPath(forItem: rowIndex, inSection: 0);
            let cell : UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath);
            if let textFieldKey = cell?.viewWithTag(200) as? UITextField {
                parameters[rowIndex - 1].key = textFieldKey.text!
                if let textFieldValue = cell?.viewWithTag(201) as? UITextField {
                    if parameters[rowIndex - 1].isInt {
                        parameters[rowIndex - 1].value = Int(textFieldValue.text!)!
                    } else {
                        parameters[rowIndex - 1].value = textFieldValue.text!
                    }
                }
                if let switchValue = cell?.viewWithTag(201) as? UISwitch {
                    parameters[rowIndex - 1].value = switchValue.on
                }
            }
        }
        if delegate != nil {
            delegate!.saveParameter(parameters)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Picker delegation methods
    var selectedType = 0
    func selectAction(sender: UIButton){
        if selectedType == 0 {
            parameters.append(ParameterStruct(key: "", value: ""))
        } else if selectedType == 1 {
            parameters.append(ParameterStruct(key: "", value: 0))
        } else {
            parameters.append(ParameterStruct(key: "", value: true))
        }
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([
            NSIndexPath(forRow: 1 + parameters.count - 1, inSection: 0)
            ], withRowAnimation: .Automatic)
        tableView.endUpdates()
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "String"
        } else if row == 1 {
            return "Number"
        } else {
            return "Bool"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = row
    }

    //MARK: Table view delegation methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: +Parameters
        return 1 + (self.parameters.count ?? 0)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            // endpoint
            cell = tableView.dequeueReusableCellWithIdentifier("NewParameterButtonCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NewParameterButtonCell")
            }
        } else {
            let parameter = parameters[indexPath.row - 1]
            if parameter.isString {
                cell = tableView.dequeueReusableCellWithIdentifier("StringParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "StringParameterCell")
                }
                if let textFieldValue = cell!.viewWithTag(201) as? UITextField {
                    if let value = parameter.value as? String {
                        textFieldValue.text = value
                    }
                }
            } else if parameter.isBool {
                cell = tableView.dequeueReusableCellWithIdentifier("BoolParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "BoolParameterCell")
                }
                if let switchValue = cell!.viewWithTag(201) as? UISwitch {
                    if let value = parameter.value as? Bool {
                        switchValue.on = value
                    }
                }
            } else if parameter.isInt {
                cell = tableView.dequeueReusableCellWithIdentifier("NumberParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NumberParameterCell")
                }
                if let textFieldValue = cell!.viewWithTag(201) as? UITextField {
                    if let number = parameter.value as? NSNumber {
                        textFieldValue.text = String(number)
                    }
                }
            }
            if let textFieldKey = cell!.viewWithTag(200) as? UITextField {
                textFieldKey.text = parameter.key
            }
        }
        return cell!
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.parameters.removeAtIndex(indexPath.row - 1)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        });
        return [deleteRowAction]
    }
}
