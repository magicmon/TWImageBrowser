//
//  DismissAnimator.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/8/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//
//  https://www.thorntech.com/2016/02/ios-tutorial-close-modal-dragging/
//  https://github.com/ThornTechPublic/InteractiveModal

import UIKit

public class DismissAnimator : NSObject {
}

extension DismissAnimator : UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView = transitionContext.containerView()
            else {
                return
        }
        
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)

        let screenBounds = UIScreen.mainScreen().bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                fromVC.view.frame = finalFrame
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
    public func animationEnded(transitionCompleted: Bool) {
//        log("\(#function) transitionCompleted: \(transitionCompleted)")
    }
}