//
//  ImageViewAnimatics.swift
//  AnimationFramework
//
//  Created by Nikita Arkhipov on 14.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class ImageAnimator: AnimationSettingsHolder, Animatics {
    typealias TargetType = UIImageView
    typealias ValueType = UIImage?
    
    let value: ValueType
    
    required init(_ v: ValueType){
        value = v
        super.init()
        _animationOptions = .transitionCrossDissolve
    }
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        Animatics_GCD_After(_delay) {
            UIView.transition(with: t, duration: self._duration, options: self._animationOptions, animations: { () -> Void in
                t.image = self.value
            }, completion: completion)
        }
    }
    
    func _performWithoutAnimationToTarget(_ t: TargetType) {
        t.image = value
    }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        t.layer.removeAllAnimations()
        t.image = value
    }
    
    func _currentValue(_ target: TargetType) -> ValueType { return target.image }
}

class ImageTintAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer{
    typealias TargetType = UIImageView
    typealias ValueType = UIColor
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ t.tintColor = value }
    func _currentValue(_ target: TargetType) -> ValueType { return target.tintColor }
}

typealias Filter = (CIImage) -> CIImage

func HueFilter(_ angle: CGFloat) -> Filter{
    let filter = CIFilter(name: "CIHueAdjust")!
    filter.setValue(NSNumber(value: Float(angle * CGFloat(M_PI)/180) as Float), forKey: kCIInputAngleKey)
    return { image in
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage!
    }
}

func SaturationFilter(_ saturation: CGFloat) -> Filter{
    let filter = CIFilter(name: "CIColorControls")!
    filter.setValue(saturation, forKey: kCIInputSaturationKey)
    return { image in
        filter.setValue(image, forKey: kCIInputImageKey)
        return filter.outputImage!
    }
}

func +(left: @escaping Filter, right: @escaping Filter) -> Filter{
    return { image in return right(left(image)) }
}

prefix operator ^
prefix func ^(filter: @escaping Filter) -> (UIImage) -> UIImage{
    return { image in UIImage(ciImage: filter(image.ciImage!)) }
}

class FilterAnimator: AnimationSettingsHolder, Animatics {
    typealias TargetType = UIImageView
    typealias ValueType = Filter
    
    let value: ValueType
    
    fileprivate var tmpImageView: UIImageView!
    
    required init(_ v: @escaping ValueType){ value = v }
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        guard let image = t.image,
            let ciimage = CIImage(image: image) else{
                return
        }
        tmpImageView = UIImageView(image: image)
        tmpImageView.frame = t.bounds
        t.addSubview(tmpImageView)
        
        t.image = UIImage(ciImage: value(ciimage))
        AlphaAnimator(0).copySettingsFrom(self).to(tmpImageView).animateWithCompletion { (completed: Bool) -> Void in
            self.tmpImageView.removeFromSuperview()
            completion?(completed)
        }
    }
    
    func _performWithoutAnimationToTarget(_ t: TargetType) {
        guard let image = t.image,
            let ciimage = CIImage(image: image) else{
                return
        }
        t.image = UIImage(ciImage: value(ciimage))
    }
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        tmpImageView?.removeFromSuperview()
    }
    
    func _currentValue(_ target: TargetType) -> ValueType { return value }
}

class FilterAndBackAnimator: AnimationSettingsHolder, Animatics {
    typealias TargetType = UIImageView
    typealias ValueType = Filter
    
    let value: ValueType
    
    fileprivate var tmpImageView: UIImageView!
    
    required init(_ v: @escaping ValueType){ value = v }
    
    func _animateWithTarget(_ t: TargetType, completion: AnimaticsCompletionBlock?){
        guard let image = t.image,
            let ciimage = CIImage(image: image) else{
                return
        }
        tmpImageView = UIImageView(image: UIImage(ciImage: value(ciimage)))
        tmpImageView.frame = t.bounds
        tmpImageView.alpha = 0
        t.addSubview(tmpImageView)
        
        let animation = (AlphaAnimator(1).copySettingsFrom(self) |-> AlphaAnimator(1).copySettingsFrom(self)).duration(_duration/2)
        animation.to(tmpImageView).animateWithCompletion { (completed: Bool) -> Void in
            self.tmpImageView.removeFromSuperview()
            completion?(completed)
        }
    }
    
    func _performWithoutAnimationToTarget(_ t: TargetType) {}
    
    func _cancelAnimation(_ t: TargetType, shouldShowFinalState: Bool) {
        tmpImageView?.removeFromSuperview()
    }
    
    func _currentValue(_ target: TargetType) -> ValueType { return value }
}
