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
}

public class EYSnapAlert
    : UIView
, CAAnimationDelegate {
    
    public typealias OnTap = (_ alert: EYSnapAlert) -> Void
    
    public typealias OnDismiss = () -> Void
    
    // MARK: Constants
    
    static let horizontalMargin: CGFloat = 30
    
    static let maxHeigtFactor: CGFloat = 0.5
    
    static let defaultDuration: TimeInterval = 2
    
    static let defaultRadius: CGFloat = 5
    
    static let containerWidthFactor: CGFloat = 1.5
    
    static let containerHeightFactor: CGFloat = 3
    
    static let animationTime: TimeInterval = 0.4
    
    // MARK: Properties
    
    public var style: EYSnapAlertStyle = .popUp
    
    public var onDismiss: OnDismiss?
    
    public var onTap: OnTap?
    
    public var duration: TimeInterval!
    
    fileprivate var width: CGFloat!
    
    fileprivate var height: CGFloat!
    
    // MARK: Public API
    
    public static func show(message: String,
                            backgroundColor: UIColor = UIColor.black,
                            textSize: CGFloat = 12,
                            textColor: UIColor = UIColor.white,
                            duration: TimeInterval = defaultDuration,
                            cornerRadius: CGFloat = defaultRadius ,
                            style: EYSnapAlertStyle = .popUp,
                            onTap: OnTap?,
                            onDimiss: OnDismiss?) {
        
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
        alert.onDismiss = onDimiss
        alert.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        alert.clipsToBounds = true
        alert.layer.cornerRadius = cornerRadius
        alert.backgroundColor = backgroundColor
        
        let label = UILabel(frame: boundRect)
        label.attributedText = str
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        alert.addSubview(label)
        label.center = CGPoint(x: alert.frame.width / 2, y: alert.frame.height / 2)
        
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
    
    public func hide(_ timer: Timer) {
        switch style {
        case .popUp:
            let anim = CABasicAnimation(keyPath: "transform.scale")
            anim.fromValue = CATransform3DMakeScale(1, 1, 1)
            anim.toValue = CATransform3DMakeScale(0, 0, 1)
            anim.duration = EYSnapAlert.animationTime
            anim.delegate = self
            anim.setValue(false, forKey: "start")
            layer.add(anim, forKey: "scaleAnimation")
            layer.transform = CATransform3DMakeScale(0, 0, 1)
        case .fade:
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = 1
            anim.toValue = 0
            anim.duration = EYSnapAlert.animationTime
            anim.delegate = self
            anim.setValue(false, forKey: "start")
            layer.add(anim, forKey: "alphaAnimation")
            alpha = 0
        }
    }
    
    fileprivate func show(style: EYSnapAlertStyle, duration: TimeInterval) {
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
            anim.duration = EYSnapAlert.animationTime
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
            anim.duration = EYSnapAlert.animationTime
            anim.delegate = self
            anim.setValue(true, forKey: "start")
            layer.add(anim, forKey: "alphaAnimation")
            layer.opacity = 1
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
                // Start timer to dismiss
                let timer = Timer(timeInterval: duration, target: self,
                                  selector: #selector(EYSnapAlert.hide(_:)), userInfo: nil, repeats: false)
                
                RunLoop.main.add(timer, forMode: .commonModes)
            } else {
                // finished dismiss
                if let onDismiss = self.onDismiss {
                    onDismiss()
                }
                
                self.removeFromSuperview()
            }
        }
    }
}
