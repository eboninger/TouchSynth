//
//  ZFRippleButton.swift
//  ZFRippleButtonDemo
//
//  Created by Amornchai Kanokpullwad on 6/26/14.
//  Copyright (c) 2014 zoonref. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class ZFRippleButton: UIButton {
    
    @IBInspectable var ripplePercent: Float = 0.8 {
        didSet {
            setupRippleView()
        }
    }
    
    @IBInspectable var rippleOverBounds: Bool = false
    
    
    @IBInspectable var rippleColor: UIColor = UIColor(white: 0.9, alpha: 0.3) {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    @IBInspectable var rippleBackgroundColor: UIColor = UIColor(white: 0.95,
        alpha: 0.65) {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    @IBInspectable var buttonCornerRadius: Float = 0 {
        didSet{
            layer.cornerRadius = CGFloat(buttonCornerRadius)
        }
    }
    
    @IBInspectable var shadowRippleRadius: Float = 25
    @IBInspectable var shadowRippleEnable: Bool = true
    @IBInspectable var trackTouchLocation: Bool = true
    
    let rippleView = UIView()
    let rippleBackgroundView = UIView()
    private var tempShadowRadius: CGFloat = 0
    private var tempShadowOpacity: Float = 0
    private var is_active: Bool = false
    
    private var rippleMask: CAShapeLayer? {
        get {
            if !rippleOverBounds {
                var maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds,
                    cornerRadius: layer.cornerRadius).CGPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        setupRippleView()
        
        rippleOverBounds = false
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        layer.addSublayer(rippleBackgroundView.layer)
        rippleBackgroundView.layer.addSublayer(rippleView.layer)
        rippleBackgroundView.alpha = 0
        
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).CGColor
    }
    
    private func setupRippleView() {
        var size: CGFloat = CGRectGetWidth(bounds) * CGFloat(ripplePercent)
        var x: CGFloat = (CGRectGetWidth(bounds)/2) - (size/2)
        var y: CGFloat = (CGRectGetHeight(bounds)/2) - (size/2)
        var corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRectMake(x, y, size, size)
        rippleView.layer.cornerRadius = corner
    }
    
    func beginTrackingWithTouch(touch: UITouch) {
            is_active = true
            if trackTouchLocation {
                rippleView.center = touch.locationInView(self)
            }
            
            UIView.animateWithDuration(0.1, animations: {
                self.rippleBackgroundView.alpha = 1
                }, completion: nil)
            
            rippleView.transform = CGAffineTransformMakeScale(0.5, 0.5)
            UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseOut,
                animations: {
                    self.rippleView.transform = CGAffineTransformIdentity
                }, completion: nil)
            
            if shadowRippleEnable {
                tempShadowRadius = layer.shadowRadius
                tempShadowOpacity = layer.shadowOpacity
                
                var shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
                shadowAnim.toValue = shadowRippleRadius
                
                var opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                opacityAnim.toValue = 1
        
                
                var groupAnim = CAAnimationGroup()
                groupAnim.duration = 0.7
                groupAnim.fillMode = kCAFillModeForwards
                groupAnim.removedOnCompletion = false
                groupAnim.animations = [shadowAnim, opacityAnim]
                
                layer.addAnimation(groupAnim, forKey:"shadow")
            }
    }
    
    func endTrackingWithTouch(touch: UITouch) {
            is_active = false
            //super.endTrackingWithTouch(touch, withEvent: event)
            
            UIView.animateWithDuration(0.1, animations: {
                self.rippleBackgroundView.alpha = 1
                }, completion: {(success: Bool) -> () in
                    UIView.animateWithDuration(0.6 , animations: {
                        self.rippleBackgroundView.alpha = 0
                        }, completion: nil)
            })
            
            UIView.animateWithDuration(0.5, delay: 0,
                options: .CurveEaseOut | .BeginFromCurrentState, animations: {
                    self.rippleView.transform = CGAffineTransformIdentity
                    
                    var shadowAnim = CABasicAnimation(keyPath:"shadowRadius")
                    shadowAnim.toValue = self.tempShadowRadius
                    
                    var opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                    opacityAnim.toValue = self.tempShadowOpacity
                    
                    var groupAnim = CAAnimationGroup()
                    groupAnim.duration = 0.5
                    groupAnim.fillMode = kCAFillModeForwards
                    groupAnim.removedOnCompletion = false
                    groupAnim.animations = [shadowAnim, opacityAnim]
                    
                    self.layer.addAnimation(groupAnim, forKey:"shadowBack")
                }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let oldCenter = rippleView.center
        setupRippleView()
        rippleView.center = oldCenter
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask    
    }
    
    func isActive() -> Bool {
        return is_active
    }
    
}