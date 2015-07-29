
import UIKit

class CashPaymentViewController: UITableViewController, UITextFieldDelegate {

    @IBAction func openCashDrawer() {
        ReceiptPrinterManager.sharedManager().openCashDrawer()
    }
    
    @IBAction func printReceipt() {
        ReceiptPrinterManager.sharedManager().printReceiptForPayment(payment!) { (sent: Bool, error: NSError?) in
            println("Sent: \(sent), Error: \(error)")
        }
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
