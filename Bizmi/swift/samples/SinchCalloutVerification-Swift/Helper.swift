import Foundation
import UIKit
import SinchVerification

// The following functions should not be considered critical to the
// functionality of the Sinch SDK.  The functions are primarily
// helpers for showing UIAlerts, and styling the sample app
// appearance.

func showError(message:String) {
    let alert = UIAlertView.init(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK");
    alert.show();
}

func showError(error: NSError){
    let message = String(format: "%@\n(%@, %ld)", error.localizedDescription, error.domain, error.code);
    showError(message);
}

func colorForPossiblePhoneNumber() -> UIColor {
    return UIColor.init(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0);
}

func colorForNotPossiblePhoneNumber() -> UIColor {
    return UIColor.init(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0);
}

func addNotificationObserver(name: String, _ closure: () -> Void) {
    NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil) { (NSNotification) -> Void in
        closure()
    }
}

func toggleActivityIndicator(activityIndicator: UIActivityIndicatorView, visible: Bool, animated: Bool) {
    if (visible) {
        activityIndicator.startAnimating();
    } else {
        activityIndicator.stopAnimating();
    }
    let alpha = visible ? 1.0 : 0.0;
    if (animated) {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            activityIndicator.alpha = CGFloat(alpha);
        })
    } else {
        activityIndicator.alpha = CGFloat(alpha);
    }
}

func initActivityIndicator(activityIndicator: UIActivityIndicatorView){
    toggleActivityIndicator(activityIndicator, visible: false, animated: false);
    
    addNotificationObserver(SINVerificationDidBeginInitiatingNotification, {
        toggleActivityIndicator(activityIndicator, visible: true, animated: true);
    });
    addNotificationObserver(SINVerificationDidEndInitiatingNotification, {
        toggleActivityIndicator(activityIndicator, visible: false, animated: true);
    });
    addNotificationObserver(SINVerificationDidBeginVerifyingCalloutNotification, {
        toggleActivityIndicator(activityIndicator, visible: true, animated: true);
    });
    addNotificationObserver(SINVerificationDidEndVerifyingCalloutNotification, {
        toggleActivityIndicator(activityIndicator, visible: false, animated: true);
    });
}

func setSinchLogoInNavigationBar(viewController: UIViewController){
    let image = UIImageView.init(image: UIImage(named: "sinch-logo-navbar"));
    image.contentMode = .ScaleAspectFill;
    viewController.navigationItem.titleView = image;
}

func initAppearance(viewController:UIViewController){
    
    setSinchLogoInNavigationBar(viewController);
    
    if let vc = viewController as? NumberEntryViewController {
        vc.setStatusText("");
        initActivityIndicator(vc.activityIndicator);
    }
}