//
//  StatusNumberTypeTableViewCell.swift
//  SampleProject
//
//  Created by Yongping on 8/29/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import UIKit

protocol StatusTableViewCellDelegate {
    func setStatus(_ sender: UITableViewCell, value: AnyObject)
}

class StatusIntTypeTableViewCell: UITableViewCell {

    var delegate: StatusTableViewCellDelegate?
    var minValue: Int? {
        didSet{
            if minValue != nil {
                valueSlider.minimumValue = Float(minValue!)
                
            }
        }
    }
    var maxValue: Int?{
        didSet{
            if maxValue != nil {
                valueSlider.maximumValue = Float(maxValue!)
            }
        }
    }
    var value: Int? {
        didSet{
            if value != nil {
                if oldValue == nil || oldValue != value! {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.valueLabel.text = "\(self.value!)"
                        self.valueSlider.value = Float(self.value!)
                    })
                }
            }
        }
    }
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusNameLabel: UILabel!

    @IBAction func changeValue(_ sender: AnyObject) {
        let valueSlider = sender as! UISlider
        let value = Int(valueSlider.value)
        self.value = value
        delegate?.setStatus(self, value: value as AnyObject)
    }
}

