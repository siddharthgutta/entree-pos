
import UIKit

class CashPaymentViewController: UITableViewController, UITextFieldDelegate {
    
    @IBAction func cancel(sender: UIBarButtonItem) {
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
    }
    
    @IBAction func done() {
        order.payment!.saveInBackground()
        
        if order.payment!.cashAmountPaid >= order.subtotal {
            completionHandler()
        } else {
            let errorAlertController = UIAlertController(title: "Oops!",
                message: "Please specify the cash amount paid before attempting to close the sale.",
                preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            errorAlertController.addAction(okayAction)
            
            presentViewController(errorAlertController, animated: true, completion: nil)
        }
    }
    
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var orderTableViewCell: UITableViewCell!
    @IBOutlet var subtotalTableViewCell: UITableViewCell!

    @IBOutlet var amountPaidTextField: UITextField!
    @IBOutlet var changeDueLabel: UILabel!
    
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
        
        amountPaidTextField.text = ""
        changeDueLabel.text = "$0.00"
    }
    
    private func printReceipt() {
        PrintingManager.sharedManager().printReceiptForOrder(order)
    }
    
    func updateChangeDue() {
        let numberFormatter = NSNumberFormatter()
        if let amountPaid = numberFormatter.numberFromString(amountPaidTextField.text!)?.doubleValue {
            let changeDue = round((amountPaid - order.subtotal) * 100) / 100
            
            changeDueLabel.text = currencyNumberFormatter.stringFromDouble(changeDue)
            
            order.payment!.cashAmountPaid = amountPaid
            order.payment!.changeGiven = amountPaid - order.subtotal
        }
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
        payment.charged = true
        
        order.payment = payment
        payment.order = order
        
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
