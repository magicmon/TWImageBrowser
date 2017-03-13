//
//  TWImageBrowserController.swift
//  TWImageBrowser
//
//  Created by magicmon on 2016. 5. 26..
//  Copyright © 2016 magicmon. All rights reserved.
//

import UIKit

public class TWImageBrowserController: UIViewController {
    
    public var interactor: Interactor? = nil
    public var threshold: CGFloat = 0.3
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TWImageBrowserController.handleGesture))
        dragRecognizer.minimumNumberOfTouches = 1
        dragRecognizer.maximumNumberOfTouches = 1
        self.view.addGestureRecognizer(dragRecognizer)
    }

    func handleGesture(sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = threshold
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
        case .Began:
            interactor.hasStarted = true
            dismissViewControllerAnimated(true, completion: nil)
        case .Changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.updateInteractiveTransition(progress)
        case .Cancelled:
            interactor.hasStarted = false
            interactor.cancelInteractiveTransition()
        case .Ended:
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finishInteractiveTransition()
                : interactor.cancelInteractiveTransition()
        default:
            break
        }
    }
}
