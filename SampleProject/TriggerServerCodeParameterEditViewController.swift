import UIKit
import ThingIFSDK

protocol TriggerServerCodeParameterEditViewControllerDelegate {
    func saveParameter(_ parameters: [ParameterStruct])
}

class TriggerServerCodeParameterEditViewController: KiiBaseTableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var parameters: [ParameterStruct] = []
    var delegate: TriggerServerCodeParameterEditViewControllerDelegate?
    
    @IBAction func tapNewParameter(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.actionSheet)
        let pickerFrame = CGRect(x: 17, y: 52, width: 270, height: 100)
        let picker = UIPickerView(frame: pickerFrame)
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        alertController.view.addSubview(picker)
        
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
        buttonCancel.addTarget(self, action: "cancelSelection:", for: UIControlEvents.touchDown)
        
        //add buttons to the view
        let buttonOkFrame: CGRect = CGRect(x: 170, y: 7, width: 100, height: 30) //size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame)
        buttonOk.setTitle("Select", for: UIControlState())
        buttonOk.setTitleColor(UIColor.blue, for: UIControlState())
        toolView.addSubview(buttonOk) //add to the subview
        
        buttonOk.addTarget(self, action: #selector(TriggerServerCodeParameterEditViewController.selectAction(_:)), for: UIControlEvents.touchDown)
        
        //add the toolbar to the alert controller
        alertController.view.addSubview(toolView)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func tapSaveParameter(_ sender: AnyObject) {
        
        for rowIndex in 0...self.tableView.numberOfRows(inSection: 0) {
            let indexPath : IndexPath = IndexPath(item: rowIndex, section: 0);
            let cell : UITableViewCell? = self.tableView.cellForRow(at: indexPath);
            if let textFieldKey = cell?.viewWithTag(200) as? UITextField {
                parameters[rowIndex - 1].key = textFieldKey.text!
                if let textFieldValue = cell?.viewWithTag(201) as? UITextField {
                    if parameters[rowIndex - 1].isInt {
                        parameters[rowIndex - 1].value = Int(textFieldValue.text!)!
                    } else {
                        parameters[rowIndex - 1].value = textFieldValue.text! as AnyObject
                    }
                }
                if let switchValue = cell?.viewWithTag(201) as? UISwitch {
                    parameters[rowIndex - 1].value = switchValue.isOn as AnyObject
                }
            }
        }
        if delegate != nil {
            delegate!.saveParameter(parameters)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Picker delegation methods
    var selectedType = 0
    func selectAction(_ sender: UIButton){
        if selectedType == 0 {
            parameters.append(ParameterStruct(key: "", value: "" as AnyObject))
        } else if selectedType == 1 {
            parameters.append(ParameterStruct(key: "", value: 0 as AnyObject))
        } else {
            parameters.append(ParameterStruct(key: "", value: true as AnyObject))
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [
            IndexPath(row: 1 + parameters.count - 1, section: 0)
            ], with: .automatic)
        tableView.endUpdates()
        self.dismiss(animated: true, completion: nil);
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "String"
        } else if row == 1 {
            return "Number"
        } else {
            return "Bool"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedType = row
    }

    //MARK: Table view delegation methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: +Parameters
        return 1 + (self.parameters.count ?? 0)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            // endpoint
            cell = tableView.dequeueReusableCell(withIdentifier: "NewParameterButtonCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "NewParameterButtonCell")
            }
        } else {
            let parameter = parameters[indexPath.row - 1]
            if parameter.isString {
                cell = tableView.dequeueReusableCell(withIdentifier: "StringParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "StringParameterCell")
                }
                if let textFieldValue = cell!.viewWithTag(201) as? UITextField {
                    if let value = parameter.value as? String {
                        textFieldValue.text = value
                    }
                }
            } else if parameter.isBool {
                cell = tableView.dequeueReusableCell(withIdentifier: "BoolParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "BoolParameterCell")
                }
                if let switchValue = cell!.viewWithTag(201) as? UISwitch {
                    if let value = parameter.value as? Bool {
                        switchValue.isOn = value
                    }
                }
            } else if parameter.isInt {
                cell = tableView.dequeueReusableCell(withIdentifier: "NumberParameterCell")
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "NumberParameterCell")
                }
                if let textFieldValue = cell!.viewWithTag(201) as? UITextField {
                    if let number = parameter.value as? NSNumber {
                        textFieldValue.text = String(describing: number)
                    }
                }
            }
            if let textFieldKey = cell!.viewWithTag(200) as? UITextField {
                textFieldKey.text = parameter.key
            }
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            self.parameters.remove(at: indexPath.row - 1)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        });
        return [deleteRowAction]
    }
}
