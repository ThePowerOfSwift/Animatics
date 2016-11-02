//
//  ColorAnimatics.swift
//  PokeScrum
//
//  Created by Nikita Arkhipov on 20.09.15.
//  Copyright © 2015 Anvics. All rights reserved.
//

import Foundation
import UIKit

class ColorViewAnimatics: AnimationSettingsHolder, AnimaticsViewChangesPerformer {
    typealias TargetType = UIView
    typealias ValueType = UIColor
    
    let value: ValueType
    
    required init(_ v: ValueType){ value = v }
    
    func _updateForTarget(_ t: TargetType){ fatalError() }
    func _currentValue(_ target: TargetType) -> ValueType{ fatalError() }
}

class BackgroundColorAnimator: ColorViewAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.backgroundColor = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.backgroundColor! }
}

class TintColorAnimator: ColorViewAnimatics {
    override func _updateForTarget(_ t: TargetType) { t.tintColor = value }
    override func _currentValue(_ target: TargetType) -> ValueType { return target.tintColor }
}
