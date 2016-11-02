//
//  TransformAnimatics.swift
//  PokeScrum
//
//  Created by Nikita Arkhipov on 19.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class IdentityTransformAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = ()
    var a: Int = 7
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    func _updateForTarget(_ t: TargetType){ t.transform = CGAffineTransform.identity }
    func _currentValue(_ target: TargetType) -> ValueType { return () }
}

class ViewTransformAnimatics: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = CGAffineTransform
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ fatalError() }
    func _currentValue(_ target: TargetType) -> ValueType { return target.transform }
}

class TransformAnimator: ViewTransformAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.transform = value }
}

class AdditiveTransformAnimator: ViewTransformAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.transform = t.transform.concatenating(value) }
}

class ScaleAnimator: ViewFloatAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.transform = CGAffineTransform(scaleX: value, y: value) }
    override func _currentValue(_ target: TargetType) -> ValueType {
        let t = target.transform
        return sqrt(t.a*t.a + t.c*t.c)
    }
}

class ScaleXYAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer{
    typealias TargetType = UIView
    typealias ValueType = (CGFloat, CGFloat)
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    func _updateForTarget(_ t: TargetType){ t.transform = CGAffineTransform(scaleX: value.0, y: value.1) }
    func _currentValue(_ target: TargetType) -> ValueType {
        let t = target.transform
        let sx = sqrt(t.a*t.a + t.c*t.c)
        let sy = sqrt(t.b*t.b + t.d*t.d)
        return (sx, sy)
    }
}

class AdditiveScaleAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.transform = t.transform.concatenating(CGAffineTransform(scaleX: value, y: value)) }
    override func _currentValue(_ target: TargetType) -> ValueType {
        let t = target.transform
        return sqrt(t.a*t.a + t.c*t.c)
    }
}

class RotateAnimator: ViewFloatAnimatics {
    convenience init(_ v: Double) { self.init(CGFloat(v)) }
    override func _updateForTarget(_ t: TargetType) { t.transform = CGAffineTransform(rotationAngle: value) }
    override func _currentValue(_ target: TargetType) -> ValueType { return atan2(target.transform.b, target.transform.a) }
}

class AdditiveRotateAnimator: ViewFloatAnimatics {
    convenience init(_ v: Double) { self.init(CGFloat(v)) }
    override func _updateForTarget(_ t: TargetType) { t.transform = t.transform.concatenating(CGAffineTransform(rotationAngle: value)) }
    override func _currentValue(_ target: TargetType) -> ValueType { return atan2(target.transform.b, target.transform.a) }
}

class XTranslateAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.transform = CGAffineTransform(translationX: value, y: 0) }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.transform.tx }
}

class YTranslateAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.transform = CGAffineTransform(translationX: 0, y: value) }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.transform.ty }
}

class TranslateAnimator: ViewPointAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.transform = CGAffineTransform(translationX: value.x, y: value.y) }
    override func _currentValue(_ target: TargetType) -> ValueType { return CGPoint(x: target.transform.tx, y: target.transform.ty) }
}
