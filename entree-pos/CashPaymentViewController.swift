
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
        if order.payment?.changeGiven >= 0 {
            order.payment?.charged = true
            order.payment?.saveInBackgroundWithBlock {
                (success, error) in
                if success {
                    self.completionHandler()
                } else {
                    print(error)
                }
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
            changeDueLabel.text = currencyNumberFormatter.stringFromDouble(payment.changeGiven)
        } else {
            fatalError("Order does not have a payment")
        }
    }
    
    private func printReceipt() {
        PrintingManager.sharedManager().printReceiptForOrder(order, fromViewController: self)
        
        let receiptSentAlertController = UIAlertController(title: "Receipt Sent!", message: "The receipt has been sent to the printer.", preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        receiptSentAlertController.addAction(okayAction)
        
        presentViewController(receiptSentAlertController, animated: true, completion: nil)
    }
    
    func updateChangeDue() {
        let numberFormatter = NSNumberFormatter()
        
        if let amountPaid = numberFormatter.numberFromString(amountPaidTextField.text!)?.doubleValue {
            order.payment?.cashAmountPaid = amountPaid
            var changeGiven = round((amountPaid - order.subtotal) * 100) / 100
            // Weird but necessary check for -0
            if changeGiven == -0 {
                changeGiven = 0
            }
            order.payment?.changeGiven = changeGiven
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
        
        // FIXME: This has error handling now (kinda), but still could be safer and asynchronous if possible
        do {
            try PFObject.saveAll([payment, order])
        } catch {
            print(error)
        }
        
        configureView()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if order.payment?.changeGiven >= 0 {
            if indexPath == NSIndexPath(forRow: 0, inSection: 2) {
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
