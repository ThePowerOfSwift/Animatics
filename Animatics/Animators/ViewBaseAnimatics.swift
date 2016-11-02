//
//  ViewFloatAnimatics.swift
//  AnimationFramework
//
//  Created by Nikita Arkhipov on 14.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class ViewFloatAnimatics: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = CGFloat
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ fatalError() }
    func _currentValue(_ target: TargetType) -> ValueType{ fatalError() }
}

class XAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.origin.x = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin.x }
}

class DXAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.origin.x += value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin.x }
}

class YAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.origin.y = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin.y }
}

class DYAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.origin.y += value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin.y }
}

class WidthAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.size.width = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.size.width }
}

class DWidthAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.size.width += value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.size.width }
}

class HeightAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.size.height = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.size.height }
}

class DHeightAnimator: ViewFloatAnimatics{
    override func _updateForTarget(_ t: TargetType) { t.frame.size.height += value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.size.height }
}

class AlphaAnimator: ViewFloatAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.alpha = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.alpha }
}


class ViewPointAnimatics: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = CGPoint
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ fatalError() }
    func _currentValue(_ target: TargetType) -> ValueType{ fatalError() }
}

class OriginAnimator: ViewPointAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.frame.origin = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin }
}

class DOriginAnimator: ViewPointAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.frame.origin.x += value.x; t.frame.origin.y += value.y }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.frame.origin }
}

class CenterAnimator: ViewPointAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.center = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.center }
}

class SizeAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = CGSize
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ t.frame.size = value }
    func _currentValue(_ target: TargetType) -> ValueType { return target.frame.size }
}

class FrameAnimator: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = CGRect
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ t.frame = value }
    func _currentValue(_ target: TargetType) -> ValueType { return target.frame }
}
