
import UIKit

class SelectPaymentTypeViewController: UITableViewController {

    @IBAction func dismiss(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
