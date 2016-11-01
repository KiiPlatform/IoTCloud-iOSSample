//
//  StatusBoolTypeTableViewCell.swift
//  SampleProject
//
//  Created by Yongping on 8/29/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit

class StatusBoolTypeTableViewCell: UITableViewCell {

    var delegate: StatusTableViewCellDelegate?

    var value: Bool? {
        didSet {
            if value != nil {
                if value != boolSwitch.isOn {
                    boolSwitch.isOn = value!
                }
            }
        }
    }

    @IBOutlet weak var boolSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusNameLabel: UILabel!

    @IBAction func changeSwitch(_ sender: AnyObject) {
        let boolSwitch = sender as! UISwitch
        value = boolSwitch.isOn
        delegate?.setStatus(self, value: boolSwitch.isOn)
    }
}
