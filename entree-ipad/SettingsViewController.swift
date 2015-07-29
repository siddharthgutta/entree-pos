
import UIKit

/* TODO: See if there are any third party tools for controlling a
   static table view. https://github.com/venmo/Static looks cool,
   but it's Swift 2 only. */

class SettingsViewController: UITableViewController {
    
    @IBOutlet var restaurantNameLabel: UILabel!
    @IBOutlet var restaurantLocationLabel: UILabel!
    
    @IBOutlet var salesTaxRateLabel: UILabel!
    @IBOutlet var alcoholTaxRateLabel: UILabel!
    
    enum TaxRateType: String {
        case Sales = "Sales"
        case Alcohol = "Alcohol"
    }
    
    let signOutTableViewCellIndexPath        = NSIndexPath(forRow: 1, inSection: 0)
    let salesTaxRateTableViewCellIndexPath   = NSIndexPath(forRow: 0, inSection: 1)
    let alcoholTaxRateTableViewCellIndexPath = NSIndexPath(forRow: 1, inSection: 1)
    
    // MARK: - SettingsViewController
    
    private func configureView() {
        let restaurantObjectID = NSUserDefaults.standardUserDefaults().objectForKey("default_restaurant") as! String
        
        PFObject(withoutDataWithClassName: Restaurant.parseClassName(), objectId: restaurantObjectID).fetchInBackgroundWithBlock {
            (restaurant: PFObject?, error: NSError?) in
            
            self.restaurantNameLabel.text = restaurant?["name"] as? String
            self.restaurantLocationLabel.text = restaurant?["location"] as? String
        }
        
        let salesTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("sales_tax_rate") as! Double
        salesTaxRateLabel.text = "\(salesTaxRate)"
        
        let alcoholTaxRate = NSUserDefaults.standardUserDefaults().objectForKey("alcohol_tax_rate") as! Double
        alcoholTaxRateLabel.text = "\(alcoholTaxRate)"
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
    
    private func editTaxRateForType(type: TaxRateType) {
        let alertController = UIAlertController(title: "Edit \(type.rawValue) Rate", message: nil, preferredStyle: .Alert)
        
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
        default:
            println()
        }
    }
    
}
