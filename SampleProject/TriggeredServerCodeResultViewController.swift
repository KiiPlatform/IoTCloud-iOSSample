import UIKit
import ThingIFSDK

class TriggeredServerCodeResultViewController: KiiBaseTableViewController {
    
    var serverCodeResults = [TriggeredServerCodeResult]()
    var trigger: Trigger? = nil
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        serverCodeResults.removeAll()
        
        self.tableView.reloadData()
        self.showActivityView(true)
        getServerCodeResults(nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverCodeResults.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ServerCodeResultCell")
        let result = serverCodeResults[indexPath.row]
        
        if result.succeeded {
            cell!.textLabel?.text = "Succeeded"
        }else {
            cell!.textLabel?.text = "Failed:" + (result.error!.errorMessage ?? "")
        }
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell!.detailTextLabel?.text = dateFormatter.stringFromDate(result.executedAt)
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func getServerCodeResults(nextPaginationKey: String?){
        if iotAPI != nil && target != nil {
            showActivityView(true)
            // use default bestEffortLimit
            iotAPI!.listTriggeredServerCodeResults((self.trigger?.triggerID)!, bestEffortLimit: 0, paginationKey: nextPaginationKey, completionHandler: { (results, paginationKey, error) -> Void in
                self.showActivityView(false)
                if results != nil {
                    for result in results! {
                        self.serverCodeResults.append(result)
                    }
                    // paginationKey is nil, then there is not more triggers, reload table
                    if paginationKey == nil {
                        self.tableView.reloadData()
                        self.showActivityView(false)
                    }else {
                        self.getServerCodeResults(paginationKey)
                    }
                }else {
                    self.showAlert("Get ServerCodeResults Failed", error: error, completion: nil)
                }
            })
        }
    }

}