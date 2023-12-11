import UIKit

final class RoundTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration = 0.4
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        
        toViewController.view.alpha = 0.0
        toViewController.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1.0
            toViewController.view.transform = CGAffineTransform.identity
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
