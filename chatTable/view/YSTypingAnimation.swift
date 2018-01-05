//
//  YSTypingAnimation.swift
//  
//
//  Created by Cem Olcay on 22/06/15.
//
//

import UIKit

struct YSTypingAnimationAppearance {
    
    var dotSize: CGFloat!
    var dotSpacing: CGFloat!
    var dotColor: UIColor!
    var dotCount: Int!
    var jumpHeight: CGFloat!
    var jumpDuration: TimeInterval!
    
    init () {
        dotSize = 5
        dotSpacing = 2
        dotColor = UIColor.black
        dotCount = 3
        jumpHeight = 5
        jumpDuration = 0.35
    }
}

class YSTypingAnimation: UIView {

    // MARK: Properties
    
    var appearance: YSTypingAnimationAppearance = YSTypingAnimationAppearance()
    var dots: [UIView] = []
    
    
    // MARK: Init
    
    init () {
        super.init(frame: CGRect(x: 0, y: 0, width: (CGFloat(appearance.dotCount) * appearance.dotSize) + (CGFloat(appearance.dotCount) * appearance.dotSpacing), height: appearance.dotSize + appearance.jumpHeight))
        
        var currentX: CGFloat = 0
        for _ in 0..<appearance.dotCount {
            
            let dot = drawDot()
            addSubview(dot)
            self.bringSubview(toFront: dot)
            dots.append(dot)
            dot.frame.origin.x = currentX
            currentX += appearance.dotSize + appearance.dotSpacing
        }
        
       startAnimating()
    }
    
    required init (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    
    // MARK: Dot
    
    func drawDot () -> UIView {
        
        let dot = UIView (frame: CGRect(x: 0, y: 0, width: appearance.dotSize, height: appearance.dotSize))
        dot.backgroundColor = appearance.dotColor
        dot.layer.cornerRadius = appearance.dotSize/2
        
        return dot
    }
    
    
    // MARK: Animation
    
    var jumpAnim: CABasicAnimation {
        get {
            let anim = CABasicAnimation(keyPath: "position.y")
            anim.fromValue = appearance.dotSize/2
            anim.toValue = appearance.jumpHeight
            anim.duration = appearance.jumpDuration
            anim.repeatCount = Float.infinity
            anim.autoreverses = true
            
            return anim
        }
    }
    
    func startAnimating () {
        
        var del: TimeInterval = 0
        
        for dot in dots {
            delay(seconds: del, queue: DispatchQueue.main, after: { () -> Void in
                dot.layer.add(self.jumpAnim, forKey: "jump")
            })
            
            del += appearance.jumpDuration / TimeInterval(appearance.jumpHeight) * TimeInterval(appearance.dotCount) * 2
        }
    }
    
    
    // MARK: Helpers
    
    func delay (
        seconds: Double,
        queue: DispatchQueue = DispatchQueue.main,
        after: @escaping () -> Void) {
        let time = DispatchTime.now()+seconds
        DispatchQueue.main.asyncAfter(deadline: time) {
            after()
        }
        //let time = dispatch_time(dispatch_time_t(DispatchTime.now()), Int64(seconds * Double(NSEC_PER_SEC)))
            //dispatch_after(time, queue, after)
    }
    
}
