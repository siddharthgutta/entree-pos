
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBAction func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantLocationLabel: UILabel!
    
    @IBOutlet var salesTaxRateLabel: UILabel!
    @IBOutlet var alcoholTaxRateLabel: UILabel!
    
    @IBOutlet var receiptPrinterNameLabel: UILabel!
    @IBOutlet var receiptPrinterMACAddressLabel: UILabel!
    
    enum TaxRateType: String {
        case Sales = "Sales"
        case Alcohol = "Alcohol"
    }
    
    let signOutTableViewCellIndexPath        = NSIndexPath(forRow: 1, inSection: 0)
    let salesTaxRateTableViewCellIndexPath   = NSIndexPath(forRow: 0, inSection: 1)
    let alcoholTaxRateTableViewCellIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    let receiptPrinterTableViewCellIndexPath = NSIndexPath(forRow: 0, inSection: 2)
    
    let percentNumberFormatter: NSNumberFormatter
    
    // MARK: - Init
    
    required init!(coder aDecoder: NSCoder!) {
        percentNumberFormatter = NSNumberFormatter()
        percentNumberFormatter.numberStyle = .PercentStyle
        percentNumberFormatter.maximumFractionDigits = 10
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - SettingsViewController
    
    private func reloadData() {
        Restaurant.asynchronouslyFetchDefaultRestaurantWithCompletion { (success: Bool, restaurant: Restaurant?) in
            if success {
                
                self.restaurantNameLabel.text = restaurant?.name
                self.restaurantLocationLabel.text = restaurant?.location
                
                self.salesTaxRateLabel.text = self.percentNumberFormatter.stringFromNumber(NSNumber(double: restaurant!.salesTaxRate))
                self.alcoholTaxRateLabel.text = self.percentNumberFormatter.stringFromNumber(NSNumber(double: restaurant!.alcoholTaxRate))
                
            } else {
                let signInViewController = UIStoryboard(name: "SignIn", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! SignInViewController
                self.presentViewController(signInViewController, animated: true, completion: nil)
            }
        }
        
        if let address = ReceiptPrinterManager.sharedManager().receiptPrinterMACAddress {
            
            ReceiptPrinterManager.sharedManager().findPrinterWithMACAddress(address) { (printer: Printer?) in
                
                self.receiptPrinterNameLabel.text = printer?.name
                self.receiptPrinterMACAddressLabel.text = printer?.macAddress
                
            }
            
        } else {
            
            receiptPrinterNameLabel.text = "Not set"
            receiptPrinterMACAddressLabel.text = ""
            
        }
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
            ReceiptPrinterManager.sharedManager().search { (printers: [Printer]) in
                let alertController = UIAlertController(title: "Select Receipt Printer", message: nil, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                for printer in printers {
                    let printerAlertAction = UIAlertAction(title: printer.name, style: .Default) { (action: UIAlertAction!) in
                        ReceiptPrinterManager.sharedManager().setReceiptPrinterMacAddress(printer.macAddress)
                    }
                    alertController.addAction(printerAlertAction)
                }
                
                self.dismissViewControllerAnimated(true) { () in
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func editTaxRateForType(type: TaxRateType) {
        let editTaxRateAlertController = UIAlertController(title: "\(type.rawValue) Tax Rate", message: "Use decimal format (i.e. 0.0825 for 8.25%).", preferredStyle: .Alert)
        
        editTaxRateAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = .NumberPad
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        editTaxRateAlertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) in
            let textField = editTaxRateAlertController.textFields?.first as! UITextField
            let taxRate = textField.text.doubleValue

            let restaurant = Restaurant.defaultRestaurantWithoutData()
            
            switch type {
            case .Alcohol:
                restaurant?.alcoholTaxRate = taxRate
            case .Sales:
                restaurant?.salesTaxRate = taxRate
            }
            
            // This call is synchronous so the alert controller will only dismiss after it has been completed.
            restaurant?.save()
            
            self.reloadData()
        }
        editTaxRateAlertController.addAction(saveAction)
        
        presentViewController(editTaxRateAlertController, animated: true, completion: nil)
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
        case salesTaxRateTableViewCellIndexPath:
            editTaxRateForType(.Sales)
        case alcoholTaxRateTableViewCellIndexPath:
            editTaxRateForType(.Alcohol)
        case receiptPrinterTableViewCellIndexPath:
            editReceiptPrinter()
        default:
            println()
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
