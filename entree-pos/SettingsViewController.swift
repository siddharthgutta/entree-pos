    
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantLocationLabel: UILabel!
    
    @IBOutlet var receiptPrinterNameLabel: UILabel!
    
    @IBOutlet var versionLabel: UILabel!
    
    let signOutTableViewCellIndexPath        = NSIndexPath(forRow: 1, inSection: 0)
    let receiptPrinterTableViewCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
    
    
    // MARK: - SettingsViewController
    
    private func reloadData() {
        Restaurant.asynchronouslyFetchDefaultRestaurantWithCompletion { (success: Bool, restaurant: Restaurant?) in
            if success {
                
                self.restaurantNameLabel.text = restaurant?.name
                self.restaurantLocationLabel.text = restaurant?.location
                
            } else {
                let signInViewController = UIStoryboard(name: "SignIn", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! SignInViewController
                self.presentViewController(signInViewController, animated: true, completion: nil)
            }
        }
        
        if let address = PrintingManager.receiptPrinterMACAddress() {
            self.receiptPrinterNameLabel.text = address
        } else {
            receiptPrinterNameLabel.text = "Not set"
        }
        
        // Version number
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        versionLabel.text = "\(version) (\(build))"
    }
    
    private func logOut() {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            if error == nil {
                let signInViewController = UIStoryboard(name: "SignIn", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! SignInViewController
                self.presentViewController(signInViewController, animated: true, completion: nil)
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    private func editReceiptPrinter() {
        let searchingAlertController = UIAlertController(title: "Searching...", message: nil, preferredStyle: .Alert)
        
        presentViewController(searchingAlertController, animated: true) { () in
            PrintingManager.sharedManager().searchForPrintersWithCompletion {
                (results) in
                
                let printers = results as [Printer]
                
                let alertController = UIAlertController(title: "Select Receipt Printer", message: nil, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                for printer in printers {
                    let printerAlertAction = UIAlertAction(title: printer.name, style: .Default) { (action: UIAlertAction!) in
                        PrintingManager.setReceiptPrinterMACAddress(printer.macAddress)
                    }
                    alertController.addAction(printerAlertAction)
                }
                
                self.dismissViewControllerAnimated(true) { () in
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath {
        case signOutTableViewCellIndexPath:
            logOut()
        case receiptPrinterTableViewCellIndexPath:
            editReceiptPrinter()
        default:
            print("wat.")
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
