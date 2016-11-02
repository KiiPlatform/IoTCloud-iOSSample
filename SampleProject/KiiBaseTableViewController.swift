//
//  KiiBaseTableViewController.swift
//  SampleProject
//
//  Created by Yongping on 8/25/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit
import ThingIFSDK

class KiiBaseTableViewController: UITableViewController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var iotAPI: ThingIFAPI?
    var target: Target?
    var schema: IoTSchema?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do{
            try iotAPI = ThingIFAPI.loadWithStoredInstance()
            self.navigationItem.title = iotAPI?.target?.typedID.id
        }catch(_){
            // do nothing
        }
        target = iotAPI?.target
        self.navigationController?.navigationItem.title = target?.typedID.id

        if schema == nil {
            if let schemaData = UserDefaults.standard.object(forKey: "schema") as? Data {
                if let schema = NSKeyedUnarchiver.unarchiveObject(with: schemaData) as? IoTSchema {
                    self.schema = schema
                }
            }
        }

        showActivityView(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showActivityView(_ show: Bool) {
        if activityIndicatorView != nil {
            if show && self.activityIndicatorView.isHidden{
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }else if !(show || self.activityIndicatorView.isHidden) {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
            }
        }
    }

    func showAlert(_ title: String, error: ThingIFError?, completion: (() -> Void)?) {
        var errorString: String?
        if error != nil {
            switch error! {
            case .connection:
                errorString = "CONNECTION"
            case .error_RESPONSE(let errorResponse):
                errorString = "{statusCode: \(errorResponse.httpStatusCode), errorCode: \(errorResponse.errorCode), message: \(errorResponse.errorMessage)}"
            case .json_PARSE_ERROR:
                errorString = "JSON_PARSE_ERROR"
            case .push_NOT_AVAILABLE:
                errorString = "PUSH_NOT_AVAILABLE"
            case .unsupported_ERROR:
                errorString = "UNSUPPORTED_ERROR"
            default:
                break
            }
        }
        showAlert(title, message: errorString, completion: completion)
    }

    func logout(_ completion: ()-> Void) {
        ThingIFAPI.removeStoredInstances()
        completion()
    }

}
