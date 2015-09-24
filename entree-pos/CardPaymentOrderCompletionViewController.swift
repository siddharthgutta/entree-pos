
import UIKit

class CardPaymentOrderCompletionViewController: UITableViewController {

    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var tipTextField: UITextField!
    
    @IBOutlet weak var chargeCell: UITableViewCell!
    
    var order: Order!
    var numberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    // MARK: - Init
    
    required init!(coder aDecoder: NSCoder) {
        
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - CardPaymentOrderCompletionViewController
    
    private func charge() {        
        let tip = tipTextField.text!.doubleValue
        self.order.tip = tip
        self.order.total = self.order.subtotal + tip
        
        let chargeConfirmationAlertController = UIAlertController(title: "Confirm", message: "Are you sure you would like to place the charge?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        chargeConfirmationAlertController.addAction(cancelAction)
        
        
        let chargeAction = UIAlertAction(title: "Charge", style: .Default) { (action: UIAlertAction!) in
            CFTCharge.captureChargeWithToken(self.order.payment!.cardFlightChargeToken!, andAmount: NSDecimalNumber(double: self.order.total), success: { (charge: CFTCharge!) in
                self.order.payment!.charged = true
                try! self.order.payment!.save()
                self.configureView()
                
                let chargedAlertController = UIAlertController(title: "Success", message: "Card was charged successfully.", preferredStyle: .Alert)
                
                let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                chargedAlertController.addAction(okayAction)
                
                self.presentViewController(chargedAlertController, animated: true, completion: nil)

            }, failure: { (error: NSError!) in
                self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
            })
        }
        chargeConfirmationAlertController.addAction(chargeAction)
        
        presentViewController(chargeConfirmationAlertController, animated: true, completion: nil)
    }
    
    private func refund() {
        CFTCharge.refundChargeWithToken(order.payment!.cardFlightChargeToken, andAmount: nil, success: { (charge: CFTCharge!) in
            let refundAlertController = UIAlertController(title: "Success", message: "This charge has been successfully refunded.", preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            refundAlertController.addAction(okayAction)
            
            self.presentViewController(refundAlertController, animated: true, completion: nil)
            
            let refund = PFObject(className: "Refund")
            refund.setValue(self.order.payment, forKey: "payment")
            
            refund.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
                if success {
                    // Doing nothing here right now.
                    // This can be handled better soon.
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        }) { (error: NSError!) in
            self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
        }
    }
    
    private func void() {
        CFTCharge.captureChargeWithToken(order.payment!.cardFlightChargeToken, andAmount: nil, success: { (charge: CFTCharge!) in
            
            charge.voidChargeWithSuccess({ () -> Void in
                let voidAlertController = UIAlertController(title: "Success", message: "This charge has been successfully voided.", preferredStyle: .Alert)
                
                let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                voidAlertController.addAction(okayAction)
                
                self.presentViewController(voidAlertController, animated: true, completion: nil)
                
                let void = PFObject(className: "Void")
                void.setValue(self.order.payment, forKey: "payment")
                
                void.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
                    if success {
                        // Doing nothing here right now.
                        // This can be handled better soon.
                    } else {
                        self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                    }
                }
            }) { (error: NSError!) in
                self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
            }
            
        }) { (error: NSError!) in
            self.presentViewController(UIAlertController.alertControllerForError(error), animated: true, completion: nil)
        }
    }
    
    private func configureView() {
        orderIDLabel.text = order.objectId!
        
        subtotalLabel.text = numberFormatter.stringFromDouble(order.subtotal)
        
        tipTextField.text = "\(order.tip)"
        
        if order.payment!.charged {
            chargeCell.textLabel?.textColor = UIColor.grayColor()
        } else {
            chargeCell.textLabel?.textColor = UIColor.entreeGreenColor()
        }
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
            if !order.payment!.charged {
                charge()
            }
        } else if indexPath == NSIndexPath(forRow: 1, inSection: 2) {
            refund()
        } else if indexPath == NSIndexPath(forRow: 2, inSection: 2) {
            void()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
