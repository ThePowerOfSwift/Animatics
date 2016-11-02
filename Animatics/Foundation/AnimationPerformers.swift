//
//  AnimationPerformers.swift
//  PokeScrum
//
//  Created by Nikita Arkhipov on 20.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

protocol AnimaticsViewChangesPerformer: Animatics{
    func _updateForTarget(_ t: TargetType)
}

extension AnimaticsViewChangesPerformer{
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        ViewAnimationPerformer.sharedInstance.animate(self, target: t, completion: completion)
    }
    func _performWithoutAnimationToTarget(_ t: TargetType){
        _updateForTarget(t)
    }
}

extension AnimaticsViewChangesPerformer where TargetType: UIView{
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        t.layer.removeAllAnimations()
        if shouldShowFinalState { _updateForTarget(t) }
    }
}

final class ViewAnimationPerformer{
    class var sharedInstance : ViewAnimationPerformer {
        struct Static {
            static let instance = ViewAnimationPerformer()
        }
        return Static.instance
    }
    
    func animate<T: AnimaticsViewChangesPerformer>(_ animator: T, target: T.TargetType, completion: AnimaticsCompletionBlock?){
        if animator._isSpring{
            UIView.animate(withDuration: animator._duration, delay: animator._delay, usingSpringWithDamping: animator._springDumping, initialSpringVelocity: animator._springVelocity, options: animator._animationOptions, animations: { () -> Void in
                animator._updateForTarget(target)
            }, completion: completion)
        }else{
            UIView.animate(withDuration: animator._duration, delay: animator._delay, options: animator._animationOptions, animations: { () -> Void in
                animator._updateForTarget(target)
            }, completion: completion)
        }
    }
}

protocol AnimaticsLayerChangesPerformer: Animatics{
    func _animationKeyPath() -> String
    func _newValue() -> AnyObject
    func _layerForTarget(_ target: TargetType) -> CALayer
}

extension AnimaticsLayerChangesPerformer{
    func _newValue() -> AnyObject { return value as AnyObject }
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        LayerAnimationPerformer.sharedInstance.animate(self, target: _layerForTarget(t), completion: completion)
    }
    func _performWithoutAnimationToTarget(_ t: TargetType) {
        _layerForTarget(t).setValue(_newValue(), forKeyPath: _animationKeyPath())
    }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        _layerForTarget(t).removeAllAnimations()
        if shouldShowFinalState { _layerForTarget(t).setValue(_newValue(), forKeyPath: _animationKeyPath()) }
    }
    
    func _currentValue(_ target: TargetType) -> ValueType {
        return _layerForTarget(target).value(forKeyPath: _animationKeyPath()) as! ValueType
    }
}

extension AnimaticsLayerChangesPerformer where TargetType: UIView{
    func _layerForTarget(_ target: TargetType) -> CALayer{ return target.layer }
}

extension AnimaticsLayerChangesPerformer where TargetType: CALayer{
    func _layerForTarget(_ target: TargetType) -> CALayer{ return target }
}

final class LayerAnimationPerformer{
    class var sharedInstance : LayerAnimationPerformer {
        struct Static {
            static let instance = LayerAnimationPerformer()
        }
        return Static.instance
    }
    
    func animate<T: AnimaticsLayerChangesPerformer, U: CALayer>(_ animator: T, target: U, completion: AnimaticsCompletionBlock?){
        let key = animator._animationKeyPath()
        
        func createAnimation() -> CABasicAnimation{
            if animator._isSpring{
                //            if #available(iOS 9, *){
                let animation = CASpringAnimation(keyPath: key)
                animation.damping = animator._springDumping * 10
                animation.initialVelocity = animator._springVelocity
                animation.duration = animation.settlingDuration
                return animation
                //            }
            }
            let animation = CABasicAnimation(keyPath: key)
            return animation
        }
        
        let fromValue = target.value(forKeyPath: key)
        target.setValue(animator._newValue(), forKeyPath: key)
        target.removeAnimation(forKey: key)
        let animation = CABasicAnimation(keyPath: key)
        
        animation.duration = animator._duration
        animation.beginTime = animator._delay
        animation.fromValue = fromValue
        target.add(animation, forKey: key)
        Animatics_GCD_After(animator._duration + animator._delay) { completion?(true) }
    }
}
