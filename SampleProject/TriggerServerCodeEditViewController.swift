import UIKit
import ThingIFSDK

protocol TriggerServerCodeEditViewControllerDelegate {
    func saveServerCode(_ serverCode: ServerCode)
}

struct ParameterStruct {
    var key: String
    var value: Any
    var isString: Bool {
        return value is NSString
    }
    var isBool: Bool {
        if let num = value as? NSNumber {
            return num.isBool()
        }
        return false
    }
    var isInt: Bool {
        if let num = value as? NSNumber {
            return num.isInt()
        }
        return false
    }
}

class TriggerServerCodeEditViewController: KiiBaseTableViewController, TriggerServerCodeParameterEditViewControllerDelegate {
    
    var serverCode: ServerCode? = nil
    var delegate: TriggerServerCodeEditViewControllerDelegate?
    var parameters: [ParameterStruct] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if parameters.isEmpty {
            if let params = serverCode?.parameters {
                for (key, value) in params {
                    parameters.append(ParameterStruct(key: key, value: value as AnyObject))
                }
            }
        }
    }
    
    @IBAction func tapNewParameter(_ sender: AnyObject) {
        var fields = Dictionary<String, String>()
        for rowIndex in 0...self.tableView.numberOfRows(inSection: 0) {
            let indexPath : IndexPath = IndexPath(item: rowIndex, section: 0);
            let cell : UITableViewCell? = self.tableView.cellForRow(at: indexPath);
            if let textField = cell?.viewWithTag(200) as? UITextField {
                fields[cell!.reuseIdentifier!] = textField.text!
            }
        }
        self.serverCode = ServerCode(
          fields["EndpointCell"]!,
          executorAccessToken: fields["ExecutorAccessTokenCell"],
          targetAppID: fields["TargetAppIDCell"],
          parameters: nil)
        self.performSegue(withIdentifier: "editServerCodeParameter", sender: self)
    }
    
    @IBAction func tapSaveServerCode(_ sender: AnyObject) {
        var fields = Dictionary<String, String>()
        for rowIndex in 0...self.tableView.numberOfRows(inSection: 0) {
            let indexPath : IndexPath = IndexPath(item: rowIndex, section: 0);
            let cell : UITableViewCell? = self.tableView.cellForRow(at: indexPath);
            if let textField = cell?.viewWithTag(200) as? UITextField {
                fields[cell!.reuseIdentifier!] = textField.text!
            }
        }

        let parameters =
          TriggerServerCodeEditViewController.parametersToDictionary(
            self.parameters)
        self.serverCode = ServerCode(
          fields["EndpointCell"]!,
          executorAccessToken: fields["ExecutorAccessTokenCell"],
          targetAppID: fields["TargetAppIDCell"],
          parameters: parameters)
        if self.delegate != nil {
            self.delegate!.saveServerCode(self.serverCode!)
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    //MARK: Table view delegation methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + (parameters.count)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            // endpoint
            cell = tableView.dequeueReusableCell(withIdentifier: "EndpointCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "EndpointCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.endpoint
            }
        } else if indexPath.row == 1 {
            // executor access token
            cell = tableView.dequeueReusableCell(withIdentifier: "ExecutorAccessTokenCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ExecutorAccessTokenCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.executorAccessToken
            }
        } else if indexPath.row == 2 {
            // target app id
            cell = tableView.dequeueReusableCell(withIdentifier: "TargetAppIDCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "TargetAppIDCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.targetAppID
            }
        } else if indexPath.row == 3 {
            // add new parameter button
            cell = tableView.dequeueReusableCell(withIdentifier: "NewParameterButtonCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "NewParameterButtonCell")
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NewParameterCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "NewParameterCell")
            }
            let parameter = parameters[indexPath.row - 4]
            var parameterString = parameter.key + " = "
            if parameter.isString {
                parameterString += parameter.value as! String
            } else if parameter.isInt {
                parameterString += String(describing: parameter.value as! NSNumber)
            } else if parameter.isBool {
                parameterString += String(parameter.value as! Bool)
            }
            cell?.textLabel?.text = parameterString
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func saveParameter(_ parameters: [ParameterStruct]) {
        self.parameters = parameters
        self.serverCode = ServerCode(
          self.serverCode!.endpoint,
          executorAccessToken: self.serverCode!.executorAccessToken,
          targetAppID: self.serverCode!.targetAppID,
          parameters:
            TriggerServerCodeEditViewController.parametersToDictionary(
              parameters))
        tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editServerCodeParameter" {
            if let editParameterVC = segue.destination as? TriggerServerCodeParameterEditViewController {
                editParameterVC.parameters = self.parameters
                editParameterVC.delegate = self
            }
        }
    }

    fileprivate static func parametersToDictionary(
      _ parameters: [ParameterStruct]) -> Dictionary<String, Any>
    {
        var retval: Dictionary<String, Any> = [ : ]
        for parameter in parameters {
            retval[parameter.key] = parameter.value
        }
        return retval
    }

}
