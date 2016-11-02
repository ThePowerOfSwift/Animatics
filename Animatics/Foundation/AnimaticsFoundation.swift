//
//  AnimaticsFoundation.swift
//  AnimationFramework
//
//  Created by Nikita Arkhipov on 14.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation

protocol AnimaticsTargetWaiter: AnimaticsSettingsSetter{
    associatedtype TargetType: AnyObject
    func to(_ t: TargetType) -> AnimaticsReady
}

protocol Animatics: AnimaticsSettingsHolder, AnimaticsTargetWaiter{
    associatedtype ValueType
    
    var value: ValueType { get }
    
    init(_ v: ValueType)
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?)
    func _performWithoutAnimationToTarget(_ t: TargetType)
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool)
    func _currentValue(_ target: TargetType) -> ValueType
}

extension Animatics{
    func to(_ target: TargetType) -> AnimaticsReady{ return AnimationReady(animator: self, target: target) }
    
    func animaticsReadyCreator() -> (TargetType) -> AnimaticsReady{ return to }
}

protocol AnimaticsReady: AnimaticsSettingsSetter {
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock?)
    func performWithoutAnimation()
    func cancelAnimation(_ shouldShowFinalState: Bool)
    func reversedAnimation() -> AnimaticsReady
}

extension AnimaticsReady{
    func animate(){ animateWithCompletion(nil) }
    func animateWithCompletion(_ completion: AnimaticsEmptyBlock?){ animateWithCompletion(emptyBlock(completion, type: Bool.self)) }
}

final class AnimationReady<T: Animatics>: AnimaticsReady, AnimaticsSettingsSettersWrapper {
    let animator: T
    let target: T.TargetType
    let reverseAnimator: T
    
    init(animator: T, target: T.TargetType){
        self.animator = animator
        self.target = target
        self.reverseAnimator = T(animator._currentValue(target))
    }
    
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock? = nil){
        animator._animateWithTarget(target, completion: completion)
    }
    
    func performWithoutAnimation(){
        animator._performWithoutAnimationToTarget(target)
    }
    
    func cancelAnimation(_ shouldShowFinalState: Bool) {
        animator._cancelAnimation(target, shouldShowFinalState: shouldShowFinalState)
    }
    
    func reversedAnimation() -> AnimaticsReady {
        return reverseAnimator.copySettingsFrom(animator).to(target)
    }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter]{ return [animator] }
}

precedencegroup LeftAssociatable{
    associativity: left
}

infix operator |-> : LeftAssociatable
infix operator ~>
infix operator ~?>
func ~><T: AnimaticsTargetWaiter>(a: T, t: T.TargetType){
    a.to(t).animate()
}

func ~><T: AnimaticsTargetWaiter>(a: T, targets: [T.TargetType]){
    for t in targets{ a.to(t).animate() }
}


func ~?><T: AnimaticsTargetWaiter>(a: T, t: T.TargetType?){
    if let t = t{ a.to(t).animate() }
}


func Animatics_GCD_After(_ seconds: Double, block: @escaping () -> ()){
    let delayTime = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        block()
    }
}

typealias AnimaticsEmptyBlock = () -> ()
func emptyBlock<T>(_ block: @escaping AnimaticsEmptyBlock, type: T.Type) -> (T) -> (){
    return { _ in block() }
}

func emptyBlock<T>(_ block: AnimaticsEmptyBlock?, type: T.Type) -> (T) -> (){
    return { _ in block?() }
}


func fillBlock<T>(_ block: @escaping (T) -> (), value: T) -> AnimaticsEmptyBlock{
    return { block(value) }
}

func fillBlock<T>(_ block: ((T) -> ())?, value: T) -> AnimaticsEmptyBlock{
    return { block?(value) }
}

