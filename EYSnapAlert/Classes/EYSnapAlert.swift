//
//  EYSnapAlert.swift
//  EYSnapAlert
//
//  Created by Enix Yu on 24/6/2017.
//  Copyright © 2017 RobotBros. All rights reserved.
//

import UIKit

public enum EYSnapAlertStyle {
    /// Fade in fade out style
    case fade
    
    /// Popup style
    case popUp
    
    /// Slide in from right
    case slideInFromRight
    
    /// Slide in from bottom
    case slideInFromBottom
    
    /// Slide from up
    case stickyUp
    
    /// Horizontal flip (3d)
    case flipHorizontal
}

public class EYSnapAlert
    : UIView
, CAAnimationDelegate {
    
    public typealias OnTap = (_ alert: EYSnapAlert) -> Void
    
    public typealias OnDismissed = () -> Void
    
    // MARK: Constants
    
    /// Default margin for horizontal border to the text
    static let horizontalMargin: CGFloat = 30
    
    /// Outter container height factor
    static let maxHeigtFactor: CGFloat = 0.5
    
    /// Default alert showing duration
    static let defaultDuration: TimeInterval = 2
    
    /// Default alert border raidus
    static let defaultRadius: CGFloat = 5
    
    /// Default outter view width factor
    static let containerWidthFactor: CGFloat = 1.5
    
    /// Default outter view height factor
    static let containerHeightFactor: CGFloat = 3
    
    /// Default alert animation time
    static let defaultAnimationTime: TimeInterval = 0.3
    
    /// Default slide offset for the sliding animation
    static let slideOffset: CGFloat = 20
    
    // MARK: Properties
    
    /// The alert showing style, @see EYSnapAlertStyle
    public var style: EYSnapAlertStyle = .popUp
    
    /// Callback when alert is dismissed
    public var onDismissed: OnDismissed?
    
    /// Callback when alert is tap
    public var onTap: OnTap?
    
    /// How long does the alert keep showing
    public var duration: TimeInterval = defaultDuration
    
    /// The animation speed, measure in seconds
    public var animationTime: TimeInterval = defaultAnimationTime
    
    fileprivate var width: CGFloat!
    
    fileprivate var height: CGFloat!
    
    fileprivate var textLabel: UILabel!
    
    // MARK: Public API
    
    /// Show an alert
    ///
    /// - parameter message: The text for the alert
    /// - parameter backgroundColor: The alert background color
    /// - parameter textSize: The font size for the alert message
    /// - parameter duration: The duration of the alert keep showing
    /// - parameter animationTime: The animation speed, measure in seconds
    /// - parameter cornerRadius: The border corner raidus for the alert view
    /// - parameter style: The alert showing animation style
    /// - parameter onTap: The callback when alert is tap
    /// - parameter onDimissed: The callback when the alert is dismissed
    public static func show(message: String,
                            backgroundColor: UIColor = UIColor.black,
                            textSize: CGFloat = 12,
                            textColor: UIColor = UIColor.white,
                            duration: TimeInterval = defaultDuration,
                            animationTime: TimeInterval = defaultAnimationTime,
                            cornerRadius: CGFloat = defaultRadius ,
                            style: EYSnapAlertStyle = .popUp,
                            onTap: OnTap? = nil,
                            onDimissed: OnDismissed? = nil) {
        
        // Calculate the width/height for the message text
        let maxWidth = UIScreen.main.bounds.width - 2 * horizontalMargin
        let maxHeight = UIScreen.main.bounds.height * maxHeigtFactor
        let attr = [NSForegroundColorAttributeName: textColor, NSFontAttributeName: UIFont.systemFont(ofSize: textSize)]
        let str = NSAttributedString(string: message, attributes: attr)
        let size = CGSize(width: maxWidth, height: maxHeight)
        let boundRect = str.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        
        // Create alert body
        let alert = EYSnapAlert(frame: CGRect.zero)
        
        // Calculate the container size
        alert.width = min(boundRect.width * containerWidthFactor, maxWidth)
        alert.height = min(boundRect.height * containerHeightFactor, maxHeight)
        let containerRect = CGRect(x: 0, y: 0, width: alert.width, height: alert.height)
        alert.frame = containerRect
        
        alert.onTap = onTap
        alert.onDismissed = onDimissed
        alert.animationTime = animationTime
        alert.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        alert.clipsToBounds = true
        alert.layer.cornerRadius = cornerRadius
        alert.backgroundColor = backgroundColor
        
        alert.textLabel = UILabel(frame: boundRect)
        alert.textLabel.attributedText = str
        alert.textLabel.numberOfLines = 0
        alert.textLabel.textAlignment = .center
        alert.textLabel.backgroundColor = UIColor.clear
        alert.addSubview(alert.textLabel)
        alert.textLabel.center = CGPoint(x: alert.frame.width / 2, y: alert.frame.height / 2)
        
        let tap = UITapGestureRecognizer(target: alert, action: #selector(EYSnapAlert.alertDidTap(_:)))
        alert.addGestureRecognizer(tap)
        
        for window in UIApplication.shared.windows.reversed() {
            if window.windowLevel == UIWindowLevelNormal && !window.isHidden {
                window.addSubview(alert)
                break
            }
        }
        
        let showDuration = duration <= 0 ? defaultDuration : duration
        alert.duration = showDuration
        alert.style = style
        alert.show(style: style, duration: showDuration)
    }
    
    /// Hide the alert explictly
    public func hide() {
        switch style {
        case .popUp:
            let anim = CABasicAnimation(keyPath: "transform.scale")
            anim.fromValue = CATransform3DMakeScale(1, 1, 1)
            anim.toValue = CATransform3DMakeScale(0, 0, 1)
            anim.duration = animationTime
            anim.delegate = self
            anim.setValue(false, forKey: "start")
            layer.add(anim, forKey: "scaleAnimation")
            layer.transform = CATransform3DMakeScale(0, 0, 1)
        case .fade:
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 1
            anim.toValue = 0
            anim.duration = animationTime
            anim.delegate = self
            anim.setValue(false, forKey: "start")
            layer.add(anim, forKey: "alphaAnimation")
            alpha = 0
        case .slideInFromRight:
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 1
            anim1.toValue = 0
            
            let toPoint = CGPoint(x: layer.position.x + EYSnapAlert.slideOffset,
                                  y: layer.position.y)
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = layer.position
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(false, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 0
            layer.position = toPoint
        case .slideInFromBottom:
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 1
            anim1.toValue = 0
            
            let toPoint = CGPoint(x: layer.position.x,
                                  y: layer.position.y + EYSnapAlert.slideOffset)
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = layer.position
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(false, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 0
            layer.position = toPoint
        case .stickyUp:
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 1
            anim1.toValue = 0
            
            let toPoint = CGPoint(x: layer.position.x,
                                  y: layer.position.y - EYSnapAlert.slideOffset)
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = layer.position
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(false, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 0
            layer.position = toPoint
        case .flipHorizontal:
            var toAngle = CATransform3DIdentity
            toAngle.m34 = -1.0 / bounds.width
            toAngle = CATransform3DRotate(toAngle, 2 * CGFloat(M_PI_2) / 3, 0, -1, 0)
            
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 1
            anim1.toValue = 0
            
            let anim2 = CABasicAnimation(keyPath: "transform")
            anim2.fromValue = CATransform3DIdentity
            anim2.toValue = toAngle
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(false, forKey: "start")
            layer.add(animGroup, forKey: "flipAnimation")
            
            layer.opacity = 0
            layer.transform = toAngle
        }
    }
    
    public func _hide(_ timer: Timer) {
        hide()
    }
    
    fileprivate func show(style: EYSnapAlertStyle, duration: TimeInterval) {
        isUserInteractionEnabled = false
        
        switch style {
        case .popUp:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            let tr = CATransform3DMakeScale(0, 0, 1)
            layer.transform = tr
            CATransaction.commit()
            
            let anim = CAKeyframeAnimation(keyPath: "transform.scale")
            anim.values = [CATransform3DMakeScale(0, 0, 1),
                           CATransform3DMakeScale(1.2, 1.2, 1),
                           CATransform3DMakeScale(1, 1, 1)]
            anim.keyTimes = [0, 0.7, 1]
            anim.duration = animationTime
            anim.delegate = self
            anim.setValue(true, forKey: "start")
            layer.add(anim, forKey: "scaleAnimation")
            layer.transform = CATransform3DMakeScale(1, 1, 1)
        case .fade:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = 0
            CATransaction.commit()
            
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = animationTime
            anim.delegate = self
            anim.setValue(true, forKey: "start")
            layer.add(anim, forKey: "alphaAnimation")
            layer.opacity = 1
        case .slideInFromRight:
            let toPoint = layer.position
            let fromPoint = CGPoint(x: layer.position.x + EYSnapAlert.slideOffset,
                                    y: layer.position.y)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = 0
            layer.position = fromPoint
            CATransaction.commit()
            
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 0
            anim1.toValue = 1
            
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = fromPoint
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(true, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 1
            layer.position = toPoint
        case .slideInFromBottom:
            let toPoint = layer.position
            let fromPoint = CGPoint(x: layer.position.x,
                                    y: layer.position.y + EYSnapAlert.slideOffset)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = 0
            layer.position = fromPoint
            CATransaction.commit()
            
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 0
            anim1.toValue = 1
            
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = fromPoint
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(true, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 1
            layer.position = toPoint
        case .stickyUp:
            let toPoint = layer.position
            let fromPoint = CGPoint(x: layer.position.x,
                                    y: layer.position.y - EYSnapAlert.slideOffset)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = 0
            layer.position = fromPoint
            CATransaction.commit()
            
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 0
            anim1.toValue = 1
            
            let anim2 = CABasicAnimation(keyPath: "position")
            anim2.fromValue = fromPoint
            anim2.toValue = toPoint
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(true, forKey: "start")
            layer.add(animGroup, forKey: "slideAnimation")
            layer.opacity = 1
            layer.position = toPoint
        case .flipHorizontal:
            var fromAngle = CATransform3DIdentity
            fromAngle = CATransform3DRotate(fromAngle, 2 * CGFloat(M_PI_2) / 3, 0, -1, 0)
            fromAngle.m34 = -1.0 / bounds.width
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.opacity = 0
            layer.transform = fromAngle
            
            // @see https://stackoverflow.com/questions/347721/how-do-i-apply-a-perspective-transform-to-a-uiview/353611#
            // zPosition need to be higher than the window layer, or half of the alert layer will be hidden
            // when appling 3D rotation to the self.layer
            layer.zPosition = 500
            CATransaction.commit()
            
            let anim1 = CABasicAnimation(keyPath: "opacity")
            anim1.fromValue = 0
            anim1.toValue = 1
            
            let anim2 = CABasicAnimation(keyPath: "transform")
            anim2.fromValue = fromAngle
            anim2.toValue = CATransform3DIdentity
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [anim1, anim2]
            animGroup.duration = animationTime
            animGroup.delegate = self
            animGroup.setValue(true, forKey: "start")
            layer.add(animGroup, forKey: "flipAnimation")
            
            layer.opacity = 1
            layer.transform = CATransform3DIdentity
        }
    }
    
    public func alertDidTap(_ gesture: UITapGestureRecognizer) {
        if let onTap = self.onTap {
            onTap(self)
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let start = anim.value(forKey: "start") as? Bool {
            if start {
                isUserInteractionEnabled = true
                // Start timer to dismiss
                let timer = Timer(timeInterval: duration, target: self,
                                  selector: #selector(EYSnapAlert._hide(_:)), userInfo: nil, repeats: false)
                
                RunLoop.main.add(timer, forMode: .commonModes)
            } else {
                // finished dismiss
                if let onDismissed = self.onDismissed {
                    onDismissed()
                }
                
                self.removeFromSuperview()
            }
        }
    }
}
