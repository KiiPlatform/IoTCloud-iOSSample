import UIKit
import ThingIFSDK

protocol TriggerServerCodeParameterEditViewControllerDelegate {
    func saveParameter(parameters: [ParameterStruct])
}

class TriggerServerCodeParameterEditViewController: KiiBaseTableViewController {
    
    var parameters: [ParameterStruct] = []
    var delegate: TriggerServerCodeParameterEditViewControllerDelegate?
    
    
    @IBAction func tapSaveParameter(sender: AnyObject) {
        if delegate != nil {
            delegate!.saveParameter(parameters)
        }
    }
    
    //        if serverCode?.parameters == nil {
    //            serverCode?.parameters = Dictionary<String, AnyObject>()
    //        }
    //        let count = serverCode?.parameters!.count
    //        serverCode?.parameters![""] = "";
    //        if count < serverCode?.parameters!.count {
    //            tableView.beginUpdates()
    //            tableView.insertRowsAtIndexPaths([
    //                NSIndexPath(forRow: 4 + serverCode!.parameters!.count - 1, inSection: 0)
    //                ], withRowAnimation: .Automatic)
    //            tableView.endUpdates()
    //        }

}
