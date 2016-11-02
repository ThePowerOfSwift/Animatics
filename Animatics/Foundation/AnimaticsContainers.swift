//
//  AnimationReady.swift
//  PokeScrum
//
//  Created by Nikita Arkhipov on 20.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation

final class SimultaneousAnimations: AnimaticsReady, AnimaticsSettingsSettersWrapper{
    fileprivate let firstAnimator: AnimaticsReady
    fileprivate let secondAnimator: AnimaticsReady
    
    init(firstAnimator: AnimaticsReady, secondAnimator: AnimaticsReady){
        self.firstAnimator = firstAnimator
        self.secondAnimator = secondAnimator
    }
    
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock?) {
        var animationsLeft = 2
        for animator in [firstAnimator, secondAnimator]{
            animator.animateWithCompletion { _ in
                animationsLeft -= 1
                if animationsLeft == 0 { completion?(true) }
            }
        }
    }
    
    func performWithoutAnimation() {
        firstAnimator.performWithoutAnimation()
        secondAnimator.performWithoutAnimation()
    }
    
    func cancelAnimation(_ shouldShowFinalState: Bool) {
        firstAnimator.cancelAnimation(shouldShowFinalState)
        secondAnimator.cancelAnimation(shouldShowFinalState)
    }
    
    func reversedAnimation() -> AnimaticsReady{
        return firstAnimator.reversedAnimation() + secondAnimator.reversedAnimation()
    }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [firstAnimator, secondAnimator] }
}

final class SequentialAnimations: AnimaticsReady, AnimaticsSettingsSettersWrapper{
    fileprivate let firstAnimator: AnimaticsReady
    fileprivate let secondAnimator: AnimaticsReady
    
    init(firstAnimator: AnimaticsReady, secondAnimator: AnimaticsReady){
        self.firstAnimator = firstAnimator
        self.secondAnimator = secondAnimator
    }
    
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock?) {
        firstAnimator.animateWithCompletion { _ in
            self.secondAnimator.animateWithCompletion(completion)
        }
    }
    
    func performWithoutAnimation() {
        firstAnimator.performWithoutAnimation()
        secondAnimator.performWithoutAnimation()
    }
    
    func cancelAnimation(_ shouldShowFinalState: Bool) {
        firstAnimator.cancelAnimation(shouldShowFinalState)
        secondAnimator.cancelAnimation(shouldShowFinalState)
    }
    
    func reversedAnimation() -> AnimaticsReady{
        return secondAnimator.reversedAnimation() |-> firstAnimator.reversedAnimation()
    }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [firstAnimator, secondAnimator] }
}

final class SimultaneousAnimationsTargetWaiter<T: AnimaticsTargetWaiter, U: AnimaticsTargetWaiter>: AnimaticsTargetWaiter, AnimaticsSettingsSettersWrapper where T.TargetType == U.TargetType{
    typealias TargetType = T.TargetType
    
    fileprivate let firstAnimator: T
    fileprivate let secondAnimator: U
    
    init(firstAnimator: T, secondAnimator: U){
        self.firstAnimator = firstAnimator
        self.secondAnimator = secondAnimator
    }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [firstAnimator, secondAnimator] }
    
    func to(_ t: TargetType) -> AnimaticsReady{
        return SimultaneousAnimations(firstAnimator: firstAnimator.to(t), secondAnimator: secondAnimator.to(t))
    }
}

final class SequentialAnimationsTargetWaiter<T: AnimaticsTargetWaiter, U: AnimaticsTargetWaiter>: AnimaticsTargetWaiter, AnimaticsSettingsSettersWrapper where T.TargetType == U.TargetType{
    typealias TargetType = T.TargetType
    
    fileprivate let firstAnimator: T
    fileprivate let secondAnimator: U
    
    init(firstAnimator: T, secondAnimator: U){
        self.firstAnimator = firstAnimator
        self.secondAnimator = secondAnimator //никитос красавчик
    }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [firstAnimator, secondAnimator] }
    
    func to(_ t: TargetType) -> AnimaticsReady{
        return SequentialAnimations(firstAnimator: firstAnimator.to(t), secondAnimator: secondAnimator.to(t))
    }
    
}

final class RepeatAnimator: AnimaticsReady, AnimaticsSettingsSettersWrapper{
    let animator: AnimaticsReady
    let repeatCount: Int
    
    init(animator: AnimaticsReady, repeatCount: Int){
        self.animator = animator
        self.repeatCount = repeatCount
    }
    
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock?) {
        animateWithCompletion(completion, repeatsLeft: repeatCount)
    }
    
    fileprivate func animateWithCompletion(_ completion: AnimaticsCompletionBlock?, repeatsLeft: Int){
        if repeatsLeft == 0 {
            completion?(true)
            return
        }
        animator.animateWithCompletion { (_)  in
            self.animateWithCompletion(completion, repeatsLeft: repeatsLeft - 1)
        }
    }
    
    func performWithoutAnimation() { }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [animator] }
    func cancelAnimation(_ shouldShowFinalState: Bool) {
        animator.cancelAnimation(shouldShowFinalState)
    }
    
    func reversedAnimation() -> AnimaticsReady{ return self }
}

final class EndlessAnimator: AnimaticsReady, AnimaticsSettingsSettersWrapper{
    let animator: AnimaticsReady
    
    init(_ animator: AnimaticsReady){
        self.animator = animator
    }
    
    func animateWithCompletion(_ completion: AnimaticsCompletionBlock?) {
        animator.animateWithCompletion { [weak self] _ in self?.animateWithCompletion(completion) }
    }
    
    func performWithoutAnimation() { }
    
    func getSettingsSetters() -> [AnimaticsSettingsSetter] { return [animator] }
    func cancelAnimation(_ shouldShowFinalState: Bool) {
        animator.cancelAnimation(shouldShowFinalState)
    }
    func reversedAnimation() -> AnimaticsReady{ return self }
}

extension AnimaticsReady{
    func endless() -> EndlessAnimator { return EndlessAnimator(self) }
}

func +(left: AnimaticsReady, right: AnimaticsReady) -> AnimaticsReady{
    return SimultaneousAnimations(firstAnimator: left, secondAnimator: right)
}

func |->(left: AnimaticsReady, right: AnimaticsReady) -> AnimaticsReady{
    return SequentialAnimations(firstAnimator: left, secondAnimator: right)
}

func +<T: AnimaticsTargetWaiter, U: AnimaticsTargetWaiter>(left: T, right: U) -> SimultaneousAnimationsTargetWaiter<T, U> where T.TargetType == U.TargetType{
    return SimultaneousAnimationsTargetWaiter(firstAnimator: left, secondAnimator: right)
}

func |-><T: AnimaticsTargetWaiter, U: AnimaticsTargetWaiter>(left: T, right: U) -> SequentialAnimationsTargetWaiter<T, U> where T.TargetType == U.TargetType{
    return SequentialAnimationsTargetWaiter(firstAnimator: left, secondAnimator: right)
}


