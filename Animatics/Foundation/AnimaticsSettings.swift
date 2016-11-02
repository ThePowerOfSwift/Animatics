//
//  AnimaticsSettings.swift
//  PokeScrum
//
//  Created by Nikita Arkhipov on 14.10.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

typealias AnimaticsCompletionBlock = (Bool) -> Void

protocol AnimaticsSettingsSetter{
    func duration(_ d: TimeInterval) -> Self
    func delay(_ d: TimeInterval) -> Self
    func baseAnimation(_ o: UIViewAnimationOptions) -> Self
    func springAnimation(_ dumping: CGFloat, velocity: CGFloat) -> Self
}

protocol AnimaticsSettingsHolder: AnimaticsSettingsSetter{
    var _duration: TimeInterval { get set }
    var _delay: TimeInterval  { get set }
    var _animationOptions: UIViewAnimationOptions { get set }
    var _isSpring: Bool { get set }
    var _springDumping: CGFloat { get set }
    var _springVelocity: CGFloat { get set }
    var _completion: AnimaticsCompletionBlock? { get set }
    func copySettingsFrom(_ source: AnimaticsSettingsHolder) -> Self
}

class AnimationSettingsHolder: AnimaticsSettingsHolder{
    var _duration: TimeInterval = 0.35
    var _delay: TimeInterval = 0
    var _animationOptions: UIViewAnimationOptions = UIViewAnimationOptions()
    var _isSpring: Bool = true
    var _springDumping: CGFloat = 0.8
    var _springVelocity: CGFloat = 0
    var _completion: AnimaticsCompletionBlock? = nil
    
    func duration(_ d: TimeInterval) -> Self{
        _duration = d
        return self
    }
    
    func delay(_ d: TimeInterval) -> Self{
        _delay = d
        return self
    }
    
    func baseAnimation(_ o: UIViewAnimationOptions = UIViewAnimationOptions()) -> Self{
        _isSpring = false
        _animationOptions = o
        return self
    }
    
    func springAnimation(_ dumping: CGFloat = 0.8, velocity: CGFloat = 0) -> Self{
        _isSpring = true
        _springDumping = dumping
        _springVelocity = velocity
        return self
    }
    
    func copySettingsFrom(_ source: AnimaticsSettingsHolder) -> Self{
        _duration = source._duration
        _delay = source._delay
        _animationOptions = source._animationOptions
        _isSpring = source._isSpring
        _springDumping = source._springDumping
        _springVelocity = source._springVelocity
        return self
    }
}

protocol AnimaticsSettingsSettersWrapper: AnimaticsSettingsSetter {
    func getSettingsSetters() -> [AnimaticsSettingsSetter]
}

extension AnimaticsSettingsSettersWrapper{
    func duration(_ d: TimeInterval) -> Self{
        for s in getSettingsSetters(){ _ = s.duration(d) }
        return self
    }
    
    func delay(_ d: TimeInterval) -> Self{
        for s in getSettingsSetters(){ _ = s.delay(d) }
        return self
        
    }
    func baseAnimation(_ o: UIViewAnimationOptions = UIViewAnimationOptions()) -> Self{
        for s in getSettingsSetters(){ _ = s.baseAnimation(o) }
        return self
    }
    
    func springAnimation(_ dumping: CGFloat = 0.8, velocity: CGFloat = 0) -> Self{
        for s in getSettingsSetters(){ _ = s.springAnimation(dumping, velocity: velocity) }
        return self
    }
}
