
import UIKit

class CashPaymentViewController: UITableViewController, UITextFieldDelegate {

    @IBAction func openCashDrawer() {
        // TODO: Open the cash drawer by sending the proper signal to the printer
        // In testing, this has not worked out great
    }
    
    @IBAction func printReceipt() {
        // TODO: Print the customer receipt
    }
    
    @IBOutlet var amountDueLabel: UILabel!
    @IBOutlet var amountPaidTextField: UITextField!
    @IBOutlet var changeDueLabel: UILabel!
    
    let numberFormatter = NSNumberFormatter()
    var payment: Payment?
    
    required init!(coder aDecoder: NSCoder!) {
        numberFormatter.numberStyle = .CurrencyStyle
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - CashPaymentViewController
    
    private func updateChangeDue() {
        if let amountDue = payment?.total {
            let amountPaid = (amountPaidTextField.text as NSString).doubleValue
            let changeDue = amountPaid - amountDue
            changeDueLabel.text = numberFormatter.stringFromNumber(NSNumber(double: changeDue))
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        updateChangeDue()
    }
    
}
