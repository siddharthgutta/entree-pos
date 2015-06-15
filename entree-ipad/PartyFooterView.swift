
import UIKit

class PartyFooterView: UIView {

    let checkoutButton: UIButton
    let customerReceiptButton: UIButton
    let kitchenReceiptButton: UIButton
    
    override init(frame: CGRect) {
        checkoutButton = UIButton.buttonWithType(.System) as! UIButton
        checkoutButton.setTitle("Checkout", forState: .Normal)
        checkoutButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        customerReceiptButton = UIButton.buttonWithType(.System) as! UIButton
        customerReceiptButton.setTitle("Customer Receipt", forState: .Normal)
        customerReceiptButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        kitchenReceiptButton = UIButton.buttonWithType(.System) as! UIButton
        kitchenReceiptButton.setTitle("Kitchen Receipt", forState: .Normal)
        kitchenReceiptButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        super.init(frame: frame)
        
        addSubview(checkoutButton)
        addSubview(customerReceiptButton)
        addSubview(kitchenReceiptButton)
        
        addConstraint(NSLayoutConstraint(item: checkoutButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: customerReceiptButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: kitchenReceiptButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: checkoutButton, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 16))
        addConstraint(NSLayoutConstraint(item: checkoutButton, attribute: .Right, relatedBy: .Equal, toItem:customerReceiptButton, attribute: .Left, multiplier: 1, constant: -8))
        addConstraint(NSLayoutConstraint(item: customerReceiptButton, attribute: .Right, relatedBy: .Equal, toItem: kitchenReceiptButton, attribute: .Left, multiplier: 1, constant: -8))
        addConstraint(NSLayoutConstraint(item: kitchenReceiptButton, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -16))
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }
    
}