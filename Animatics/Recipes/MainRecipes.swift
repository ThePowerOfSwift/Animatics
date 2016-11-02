//
//  MainRecipes.swift
//  ForestLand
//
//  Created by Nikita Arkhipov on 21.12.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class ShakeAnimator: AnimationSettingsHolder, Animatics{
    typealias TargetType = UIView
    typealias ValueType = Void
    
    let v = 7
    let value: ValueType
    
    required init(_ v: ValueType){
        value = v
        super.init()
        _duration = 0.24
    }
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        let CGM_PI = CGFloat(M_PI)
        (RotateAnimator(CGM_PI/12).delay(_delay).duration(_duration/4) |->
            RotateAnimator(-CGM_PI/6).duration(_duration/2) |->
            RotateAnimator(0.0).duration(_duration/4)).baseAnimation(.curveLinear).to(t).animateWithCompletion(completion)
    }
    
    func _performWithoutAnimationToTarget(_ t: TargetType) { }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) { }
    func _currentValue(_ target: TargetType) -> ValueType { return () }
}

class ScaleAndBackAnimator: AnimationSettingsHolder, Animatics{
    typealias TargetType = UIView
    typealias ValueType = CGFloat
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        (ScaleAnimator(value).copySettingsFrom(self) |-> TransformAnimator(t.transform).copySettingsFrom(self)).duration(_duration/2).to(t).animateWithCompletion(completion)
    }
    
    func _performWithoutAnimationToTarget(_ t: TargetType) { }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        t.layer.removeAllAnimations()
    }
    
    func _currentValue(_ target: TargetType) -> ValueType { return 1 }
    
}
