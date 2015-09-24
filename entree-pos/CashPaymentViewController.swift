
import UIKit

class CashPaymentViewController: UITableViewController, UITextFieldDelegate {
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Only delete the order if the party is not nil
        if let _ = order.party {
            for orderItem in order.orderItems {
                orderItem.order = nil
            }
            PFObject.saveAllInBackground(order.orderItems)
            
            PFObject.deleteAllInBackground([order, order.payment!]) {
                (succeeded, error) in
                if succeeded {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
        } else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    @IBAction func done() {
        order.payment!.saveInBackground()
        
        if order.payment!.cashAmountPaid >= order.subtotal {
            order.payment?.charged = true
            order.payment?.saveInBackgroundWithBlock {
                (success, error) in
                self.completionHandler()
            }
        } else {
            let errorAlertController = UIAlertController(title: "Oops!",
                message: "Please specify the cash amount paid before attempting to close the sale.",
                preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            errorAlertController.addAction(okayAction)
            
            presentViewController(errorAlertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var orderTableViewCell: UITableViewCell!
    @IBOutlet weak var subtotalTableViewCell: UITableViewCell!

    @IBOutlet weak var amountPaidTextField: UITextField!
    @IBOutlet weak var changeDueLabel: UILabel!
    
    var currencyNumberFormatter: NSNumberFormatter {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        return formatter
    }
    
    var order: Order!
    var completionHandler: (() -> Void)!
    
    // MARK: - CashPaymentViewController
    
    private func configureView() {
        orderTableViewCell.detailTextLabel?.text = order.objectId!
        subtotalTableViewCell.detailTextLabel?.text = currencyNumberFormatter.stringFromDouble(order.subtotal)
        
        if let payment = order.payment {
            amountPaidTextField.text = currencyNumberFormatter.stringFromDouble(payment.cashAmountPaid)
            changeDueLabel.text = currencyNumberFormatter.stringFromDouble(round(payment.changeGiven * 100) / 100)
        } else {
            fatalError("Order does not have a payment")
        }
    }
    
    private func printReceipt() {
        PrintingManager.sharedManager().printReceiptForOrder(order)
        
        let receiptSentAlertController = UIAlertController(title: "Receipt Sent!", message: "The receipt has been sent to the printer.", preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        receiptSentAlertController.addAction(okayAction)
        
        presentViewController(receiptSentAlertController, animated: true, completion: nil)
    }
    
    func updateChangeDue() {
        let numberFormatter = NSNumberFormatter()
        
        if let amountPaid = numberFormatter.numberFromString(amountPaidTextField.text!)?.doubleValue {
            order.payment?.cashAmountPaid = amountPaid
            order.payment?.changeGiven = amountPaid - order.subtotal
        }
        
        configureView()
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountPaidTextField.addTarget(self, action: "updateChangeDue", forControlEvents: .EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let payment = Payment()
        payment.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        payment.type = "Cash"
        
        order.payment = payment
        payment.order = order
        
        // Synchronous and dangerous
        try! PFObject.saveAll([payment, order])
        
        configureView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if order.payment!.cashAmountPaid >= order.subtotal {
            if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
                order.payment!.saveInBackground()
                
                printReceipt()
            }
        } else {
            let errorAlertController = UIAlertController(title: "Oops!",
                message: "Please first specify a cash amount paid that is greater than or equal to the subtotal due.",
                preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            errorAlertController.addAction(okayAction)
            
            presentViewController(errorAlertController, animated: true, completion: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
