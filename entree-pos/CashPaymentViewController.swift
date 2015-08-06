
import UIKit

class CashPaymentViewController: UITableViewController, UITextFieldDelegate {
    
    @IBAction func done() {
        if let order = order {
            let payment = Payment()
            payment.type = "Cash"
            payment.order = order
            
            order.payment = payment
            
            PFObject.saveAllInBackground([payment, order]) { (success: Bool, error: NSError?) in
                if success {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    @IBOutlet var amountDueLabel: UILabel!
    @IBOutlet var amountPaidTextField: UITextField!
    @IBOutlet var changeDueLabel: UILabel!
    
    let numberFormatter = NSNumberFormatter.numberFormatterWithStyle(.CurrencyStyle)
    var order: Order?
    
    // MARK: - CashPaymentViewController
    
    private func openCashDrawer() {
        ReceiptPrinterManager.sharedManager().openCashDrawer()
    }
    
    private func printReceipt() {
        ReceiptPrinterManager.sharedManager().printReceiptForOrder(order!) { (sent: Bool, error: NSError?) in
            println("Sent: \(sent), Error: \(error)")
        }
    }
    
    private func updateChangeDue() {
        if let amountDue = order?.total() {
            let amountPaid = (amountPaidTextField.text as NSString).doubleValue
            let changeDue = amountPaid - amountDue
            changeDueLabel.text = numberFormatter.stringFromNumber(NSNumber(double: changeDue))
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            openCashDrawer()
        } else if indexPath.section == 3 {
            printReceipt()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateChangeDue()
    }
    
}
