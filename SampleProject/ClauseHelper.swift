//
//  ClauseHelper.swift
//  SampleProject
//
//  Created by Yongping on 8/29/15.
//  Copyright © 2015 Kii Corporation. All rights reserved.
//

import Foundation
import ThingIFSDK

enum ClauseType: String {
    case And = "And"
    case Or = "Or"
    case Equals = "="
    case NotEquals = "!="
    case LessThan = "<"
    case GreaterThan = ">"
    case LessThanOrEquals = "<="
    case GreaterThanOrEquals = ">="
    case LeftOpen = "( ]"
    case RightOpen = "[ )"
    case BothOpen = "( )"
    case BothClose = "[ ]"

    static func getTypesArray() -> [ClauseType] {
        return [ClauseType.And,
            ClauseType.Or,
            ClauseType.Equals,
            ClauseType.NotEquals,
            ClauseType.LessThan,
            ClauseType.LessThanOrEquals,
            ClauseType.GreaterThan,
            ClauseType.GreaterThanOrEquals,
            ClauseType.BothOpen,
            ClauseType.BothClose,
            ClauseType.LeftOpen,
            ClauseType.RightOpen
        ]
    }

    static func getClauseType(_ clause: TriggerClause) -> ClauseType? {
        if clause is AndClauseInTrigger {
            return ClauseType.And
        }else if clause is OrClauseInTrigger {
            return ClauseType.Or
        }else if clause is EqualsClauseInTrigger {
            return ClauseType.Equals
        }else if clause is NotEqualsClauseInTrigger {
            return ClauseType.NotEquals
        } else if clause is RangeClauseInTrigger {
            let range = clause as! RangeClauseInTrigger
            if let _ = range.lowerLimit, let _ = range.upperLimit, let lowerIncluded = range.lowerIncluded, let upperIncluded = range.upperIncluded {
                if lowerIncluded && upperIncluded {
                    return ClauseType.BothClose
                }else if !lowerIncluded && upperIncluded {
                    return ClauseType.LeftOpen
                }else if lowerIncluded && !upperIncluded {
                    return ClauseType.RightOpen
                }else {
                    return ClauseType.BothOpen
                }
            }

            if let _ = range.lowerLimit, let lowerIncluded = range.lowerIncluded {
                if lowerIncluded {
                    return ClauseType.GreaterThanOrEquals
                }else {
                    return ClauseType.GreaterThan
                }
            }

            if let _ = range.upperLimit, let upperIncluded = range.upperIncluded {
                if upperIncluded {
                    return ClauseType.LessThanOrEquals
                }else {
                    return ClauseType.LessThan
                }
            }
            return nil
        }else{
            return nil
        }
    }

}

class ClauseHelper {

    static func getInitializedClause(_ alias: String, clauseType: ClauseType, statusSchema: StatusSchema?) -> TriggerClause? {
        var initializedClause: TriggerClause?

        if clauseType == ClauseType.And {
            initializedClause = AndClauseInTrigger()
        }else if clauseType == ClauseType.Or {
            initializedClause = OrClauseInTrigger()
        }

        if statusSchema != nil {
            let statusType = statusSchema!.type
            let statusName = statusSchema!.name
            switch clauseType {
            case .Equals:
                switch statusType! {
                case StatusType.BoolType:
                    initializedClause = EqualsClauseInTrigger(alias, field: statusName!, boolValue: false)
                case StatusType.IntType:
                    initializedClause = EqualsClauseInTrigger(alias, field: statusName!, intValue: 0)
                case StatusType.StringType:
                    initializedClause = EqualsClauseInTrigger(alias, field: statusName!, stringValue: "")
                default:
                    break
                }

            case .NotEquals:
                switch statusType! {
                case StatusType.BoolType:
                    initializedClause = NotEqualsClauseInTrigger(EqualsClauseInTrigger(alias, field: statusName!, boolValue: false))
                case StatusType.IntType:
                    initializedClause = NotEqualsClauseInTrigger(EqualsClauseInTrigger(alias, field: statusName!, intValue: 0))
                case StatusType.StringType:
                    initializedClause = NotEqualsClauseInTrigger(EqualsClauseInTrigger(alias, field: statusName!, stringValue: ""))
                default:
                    break
                }

            case .LessThan:
                switch statusType! {
                case StatusType.IntType:
                    initializedClause = RangeClauseInTrigger.lessThan(alias, field: statusName!, limit: 0)
                case StatusType.DoubleType:
                    initializedClause = RangeClauseInTrigger.lessThan(alias, field: statusName!, limit: 0.0)
                default:
                    break
                }

            case .LessThanOrEquals:
                switch statusType! {
                case StatusType.IntType:
                    initializedClause = RangeClauseInTrigger.lessThanOrEqualTo(alias, field: statusName!, limit: 0)
                case StatusType.DoubleType:
                    initializedClause = RangeClauseInTrigger.lessThanOrEqualTo(alias, field: statusName!, limit: 0.0)
                default:
                    break
                }

            case .GreaterThan:
                switch statusType! {
                case StatusType.IntType:
                    initializedClause = RangeClauseInTrigger.greaterThan(alias, field: statusName!, limit:0)
                case StatusType.DoubleType:
                    initializedClause = RangeClauseInTrigger.greaterThan(alias, field: statusName!, limit:0.0)
                default:
                    break
                }
            case .GreaterThanOrEquals:
                switch statusType! {
                case StatusType.IntType:
                    initializedClause = RangeClauseInTrigger.greaterThanOrEqualTo(alias, field: statusName!, limit:0)
                case StatusType.DoubleType:
                    initializedClause = RangeClauseInTrigger.greaterThanOrEqualTo(alias, field: statusName!, limit:0.0)
                default:
                    break
                }

            case .LeftOpen, .RightOpen, .BothClose, .BothOpen:
                let upperIncluded: Bool!
                if clauseType == ClauseType.LeftOpen || clauseType == ClauseType.BothClose {
                    upperIncluded = true
                }else {
                    upperIncluded = false
                }

                let lowerIncluded: Bool!
                if clauseType == ClauseType.RightOpen || clauseType == ClauseType.BothClose {
                    lowerIncluded = true
                }else {
                    lowerIncluded = false
                }

                switch statusType! {
                case StatusType.IntType:
                    initializedClause = RangeClauseInTrigger.range(alias, field: statusName!, lowerLimit: 0, lowerIncluded: lowerIncluded, upperLimit: 0, upperIncluded: upperIncluded)
                case StatusType.DoubleType:
                    initializedClause = RangeClauseInTrigger.range(alias, field: statusName!, lowerLimit: 0.0, lowerIncluded: lowerIncluded, upperLimit: 0.0, upperIncluded: upperIncluded)
                default:
                    break
                }
                
            default:
                break
            }
            
        }
        return initializedClause
    }

    static func getStatusFromClause(_ clause: TriggerClause) -> String {
        let clauseType = ClauseType.getClauseType(clause)!

        switch clauseType {
        case .NotEquals:
            return (clause as! NotEqualsClauseInTrigger).equals.field
        case .Equals:
            return (clause as! EqualsClauseInTrigger).field
        case .LessThan, .LessThanOrEquals, .GreaterThan, .GreaterThanOrEquals, .BothOpen, .BothClose, .LeftOpen, .RightOpen:
            return (clause as! RangeClauseInTrigger).field
        case .And, .Or:
            return ""
        }
    }

    static func getNewClause(_ alias: String, clause: RangeClauseInTrigger, lowerLimitValue: AnyObject, upperLimitValue: AnyObject, statusSchema: StatusSchema) -> RangeClauseInTrigger? {
        var newClause: RangeClauseInTrigger?
        let status = statusSchema.name
        if let clauseType = ClauseType.getClauseType(clause), let statusType = statusSchema.type {
            switch clauseType {
            case .LeftOpen, .RightOpen, .BothClose, .BothOpen:

                let upperIncluded: Bool!
                if clauseType == ClauseType.LessThan {
                    upperIncluded = false
                }else {
                    upperIncluded = true
                }

                let lowerIncluded: Bool!
                if clauseType == ClauseType.LessThan {
                    lowerIncluded = false
                }else {
                    lowerIncluded = true
                }

                switch statusType {
                case StatusType.IntType:
                    newClause = RangeClauseInTrigger.range(alias, field: status!, lowerLimit: lowerLimitValue as! NSNumber, lowerIncluded: lowerIncluded, upperLimit: upperLimitValue as! NSNumber, upperIncluded: upperIncluded)
                default:
                    break
                }

            default:
                break
            }
        }
        return newClause
    }

    static func getNewClause(_ alias: String, clause: TriggerClause, singleValue: Any, statusSchema: StatusSchema) -> TriggerClause?{
        var newClause: TriggerClause?
        let status = statusSchema.name
        if let clauseType = ClauseType.getClauseType(clause), let statusType = statusSchema.type {
            switch clauseType {
            case .Equals:
                switch statusType {
                case StatusType.IntType:
                    newClause = EqualsClauseInTrigger(alias, field: status!, intValue: singleValue as! Int)
                case StatusType.BoolType:
                    newClause = EqualsClauseInTrigger(alias, field: status!, boolValue: singleValue as! Bool)
                default:
                    break
                }
            case .NotEquals:
                switch statusType {
                case StatusType.IntType:
                    newClause = NotEqualsClauseInTrigger(EqualsClauseInTrigger(alias, field: status!, intValue: singleValue as! Int))
                case StatusType.BoolType:
                    newClause = NotEqualsClauseInTrigger(EqualsClauseInTrigger(alias, field: status!, boolValue: singleValue as! Bool))
                default:
                    break
                }
            case .LessThan:
                switch statusType {
                case StatusType.IntType:
                    newClause = RangeClauseInTrigger.lessThan(alias, field: status!, limit: singleValue as! NSNumber)
                default:
                    break
                }
            case .LessThanOrEquals:
                switch statusType {
                case StatusType.IntType:
                    newClause = RangeClauseInTrigger.lessThanOrEqualTo(alias, field: status!, limit: singleValue as! NSNumber)
                default:
                    break
                }
            case .GreaterThan:
                switch statusType {
                case StatusType.IntType:
                    newClause = RangeClauseInTrigger.greaterThan(alias, field: status!, limit: singleValue as! NSNumber)
                default:
                    break
                }
            case .GreaterThanOrEquals:
                switch statusType {
                case StatusType.IntType:
                    newClause = RangeClauseInTrigger.greaterThanOrEqualTo(alias, field: status!, limit: singleValue as! NSNumber)
                default:
                    break
                }
            default:
                break
            }
        }
        return newClause
    }

}
