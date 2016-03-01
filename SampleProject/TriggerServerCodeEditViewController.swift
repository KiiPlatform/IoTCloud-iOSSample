import UIKit
import ThingIFSDK

protocol TriggerServerCodeEditViewControllerDelegate {
    func saveServerCode(serverCode: ServerCode)
}

struct ParameterStruct {
    var key: String
    var value: AnyObject
}

class TriggerServerCodeEditViewController: KiiBaseTableViewController, TriggerServerCodeParameterEditViewControllerDelegate {
    
    var serverCode: ServerCode? = nil
    var delegate: TriggerServerCodeEditViewControllerDelegate?
    var parameters: [ParameterStruct] = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let params = serverCode?.parameters {
            for (key, value) in params {
                parameters.append(ParameterStruct(key: key, value: value))
            }
        }
    }
    
    @IBAction func tapNewParameter(sender: AnyObject) {
        self.performSegueWithIdentifier("editServerCodeParameter", sender: self)
    }
    
    @IBAction func tapSaveServerCode(sender: AnyObject) {
        var fields = Dictionary<String, String>()
        for rowIndex in 0...self.tableView.numberOfRowsInSection(0) {
            let indexPath : NSIndexPath = NSIndexPath(forItem: rowIndex, inSection: 0);
            let cell : UITableViewCell? = self.tableView.cellForRowAtIndexPath(indexPath);
            if let textField = cell?.viewWithTag(200) as? UITextField {
                fields[cell!.reuseIdentifier!] = textField.text!
            }
        }
        self.serverCode!.endpoint = fields["EndpointCell"]!
        self.serverCode!.executorAccessToken = fields["ExecutorAccessTokenCell"]!
        self.serverCode!.targetAppID = fields["TargetAppIDCell"]!
        self.serverCode!.parameters = Dictionary<String, AnyObject>()
        for parameter in self.parameters {
           self.serverCode!.parameters![parameter.key] = parameter.value
        }
        if self.delegate != nil {
            self.delegate!.saveServerCode(self.serverCode!)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Table view delegation methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: +Parameters
        return 4 + (serverCode?.parameters?.count ?? 0)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.row == 0 {
            // endpoint
            cell = tableView.dequeueReusableCellWithIdentifier("EndpointCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "EndpointCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.endpoint
            }
        } else if indexPath.row == 1 {
            // executor access token
            cell = tableView.dequeueReusableCellWithIdentifier("ExecutorAccessTokenCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ExecutorAccessTokenCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.executorAccessToken
            }
        } else if indexPath.row == 2 {
            // target app id
            cell = tableView.dequeueReusableCellWithIdentifier("TargetAppIDCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TargetAppIDCell")
            }
            if let textField = cell!.viewWithTag(200) as? UITextField {
                textField.text = serverCode!.targetAppID
            }
        } else if indexPath.row == 3 {
            // add new parameter button
            cell = tableView.dequeueReusableCellWithIdentifier("NewParameterButtonCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NewParameterButtonCell")
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("NewParameterCell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NewParameterCell")
            }
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func saveParameter(parameters: [ParameterStruct]) {
        self.parameters = parameters
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editServerCodeParameter" {
            if let editParameterVC = segue.destinationViewController as? TriggerServerCodeParameterEditViewController {
                editParameterVC.parameters = self.parameters
                editParameterVC.delegate = self
            }
        }
    }

}
