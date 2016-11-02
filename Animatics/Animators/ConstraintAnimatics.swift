//
//  ConstraintAnimatics.swift
//  BlackStar
//
//  Created by Nikita Arkhipov on 25.11.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class ConstraintAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = NSLayoutConstraint
    typealias ValueType = CGFloat
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){
        t.constant = value
        (t.firstItem as? UIView)?.layoutIfNeeded()
        (t.secondItem as? UIView)?.layoutIfNeeded()
    }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        (t.firstItem as? UIView)?.layer.removeAllAnimations()
        (t.secondItem as? UIView)?.layer.removeAllAnimations()
        if shouldShowFinalState { _updateForTarget(t) }
    }
    
    func _currentValue(_ target: TargetType) -> ValueType { return target.constant }
    
}
