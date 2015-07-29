
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
    
    // MARK: - SettingsViewController
    
    private func configureView() {
        let restaurantObjectID = NSUserDefaults.standardUserDefaults().objectForKey("default_restaurant") as! String
        
        PFObject(withoutDataWithClassName: Restaurant.parseClassName(), objectId: restaurantObjectID).fetchInBackgroundWithBlock {
            (restaurant: PFObject?, error: NSError?) in
            
            self.restaurantNameLabel.text = restaurant?["name"] as? String
            self.restaurantLocationLabel.text = restaurant?["location"] as? String
        }
        
        if let salesTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("sales_tax_rate") as? Double {
            salesTaxRateLabel.text = "\(salesTaxRate)"
        } else {
            NSUserDefaults.standardUserDefaults().setObject(Double(0), forKey: "sales_tax_rate")
            
            salesTaxRateLabel.text = "0"
        }
        
        if let alcoholTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("alcohol_tax_rate") as? Double {
            alcoholTaxRateLabel.text = "\(alcoholTaxRate)"
        } else {
            NSUserDefaults.standardUserDefaults().setObject(Double(0), forKey: "alcohol_tax_rate")
            
            alcoholTaxRateLabel.text = "0"
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
            if error != nil {
                // Clear current restaurant
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "shared_restaurant_object_id")
                
                // TODO: get to base of nav stack
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    private func editReceiptPrinter() {
        let alertController = UIAlertController(title: "Select Receipt Printer", message: nil, preferredStyle: .Alert)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        
        ReceiptPrinterManager.sharedManager().search { (printers: [Printer]) in
            for printer in printers {
                let printerAlertAction = UIAlertAction(title: printer.name, style: .Default) { (action: UIAlertAction!) in
                    ReceiptPrinterManager.sharedManager().setReceiptPrinterMacAddress(printer.macAddress)
                }
                alertController.addAction(printerAlertAction)
            }
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    private func editTaxRateForType(type: TaxRateType) {
        let alertController = UIAlertController(title: "Edit \(type.rawValue) Tax Rate", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.keyboardType = .NumberPad
            textField.placeholder = "Example: 0.0825"
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAlertAction)
        
        let saveAlertAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) in
            let textField = alertController.textFields!.first! as! UITextField
            let rate = textField.text.doubleValue

            NSUserDefaults.standardUserDefaults().setObject(rate, forKey: "\(type.rawValue.lowercaseString)_tax_rate")
            
            self.configureView()
        }
        alertController.addAction(saveAlertAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
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
