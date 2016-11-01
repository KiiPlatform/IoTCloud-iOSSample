import UIKit
import ThingIFSDK

class TriggeredServerCodeResultViewController: KiiBaseTableViewController {
    
    var serverCodeResults = [TriggeredServerCodeResult]()
    var trigger: Trigger? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        serverCodeResults.removeAll()
        
        self.tableView.reloadData()
        self.showActivityView(true)
        getServerCodeResults(nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverCodeResults.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCodeResultCell")
        let result = serverCodeResults[indexPath.row]
        
        if result.succeeded {
            cell!.textLabel?.text = "Succeeded"
        }else {
            cell!.textLabel?.text = "Failed:" + (result.error!.errorMessage ?? "")
        }
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        cell!.detailTextLabel?.text = dateFormatter.string(from: result.executedAt)
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func getServerCodeResults(_ nextPaginationKey: String?){
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
