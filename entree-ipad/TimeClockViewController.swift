
import UIKit

class TimeClockViewController: PFQueryCollectionViewController, THPinViewControllerDelegate {

    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var avatarCache = [String: UIImage]()
    var employees = [Employee]()
    var selectedEmployee: Employee?
    
    // MARK: - TimeClockViewController
    
    private func presentPinViewControllerFromCollectionViewCell(cell: UICollectionViewCell) {
        let pinViewController = THPinViewController(delegate: self)
        pinViewController.backgroundColor = UIColor.entreeBlueColor()
        pinViewController.hideLetters = true
        pinViewController.promptColor = UIColor.whiteColor()
        pinViewController.promptTitle = "Enter PIN"
        pinViewController.view.tintColor = UIColor.whiteColor()
        
        pinViewController.modalPresentationStyle = .Popover
        pinViewController.preferredContentSize = CGSizeMake(400, 600)
        
        self.presentViewController(pinViewController, animated: true, completion: nil)
        
        let popover = pinViewController.popoverPresentationController!
        popover.backgroundColor = UIColor.entreeBlueColor()
        popover.permittedArrowDirections = .Left | .Right
        popover.sourceRect = cell.contentView.bounds
        popover.sourceView = cell.contentView
    }
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = Employee.query()!
        
        if segmentedControl.selectedSegmentIndex == 0 {
            query.whereKey("role", equalTo: "Server")
        } else {
            query.whereKey("role", notEqualTo: "Server")
        }
        
        return query
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? ShadedImageCollectionViewCell {
            let employee = objectAtIndexPath(indexPath)! as! Employee
            
            cell.shadedImageView.image = nil
            
            if let avatar = avatarCache[employee.objectId!] {
                cell.shadedImageView.image = avatar
            }
            
            if let avatarFile = employee.avatarFile {
                avatarFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
                    if let imageData: NSData = data, let avatar = UIImage(data: imageData) {
                        self.avatarCache[employee.objectId!] = avatar
                        
                        cell.shadedImageView.image = avatar
                        
                        cell.setNeedsDisplay()
                    } else {
                        println(error)
                        
                        cell.shadedImageView.backgroundColor = UIColor.darkGrayColor()
                    }
                }
            } else {
                cell.shadedImageView.backgroundColor = UIColor.darkGrayColor()
            }
            
            cell.primaryTextLabel.text = employee.name
            cell.detailTextLabel.text = employee.role
            
            if employee.currentShift != nil {
                cell.badgeLabel.text = "In"
                cell.badgeLabel.badgeColor = UIColor.entreeGreenColor()
            } else {
                cell.badgeLabel.text = "Out"
                cell.badgeLabel.badgeColor = UIColor.entreeRedColor()
            }
            
            return cell
        }
        
        return nil
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case "ServerMap":
                if let navigationController = segue.destinationViewController as? UINavigationController, let serverMapViewController = navigationController.viewControllers.first as? ServerMapViewController {
                    serverMapViewController.employee = selectedEmployee
                }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.registerNib(UINib(nibName: "ShadedImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
 
        segmentedControl.addTarget(self, action: Selector("loadObjects"), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadObjects()
    }
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let employee = objectAtIndexPath(indexPath) as! Employee
        
        selectedEmployee = employee
        
        if employee.currentShift != nil {
            presentPinViewControllerFromCollectionViewCell(collectionView.cellForItemAtIndexPath(indexPath)!)
        } else {
            let alertController = UIAlertController(title: "You must clock-in", message: "Please clock-in before accessing your tables", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Clock-in", style: .Default) { (action: UIAlertAction!) in
                let shift = Shift()
                shift.employee = employee
                shift.startedAt = NSDate()
                shift.saveEventually(nil)
                
                employee.currentShift = shift
                employee.saveEventually(nil)
                
                self.loadObjects()
                
                self.presentPinViewControllerFromCollectionViewCell(collectionView.cellForItemAtIndexPath(indexPath)!)
            })

            alertController.modalPresentationStyle = .Popover
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - THPinViewControllerDelegate
    
    func pinLengthForPinViewController(pinViewController: THPinViewController!) -> UInt {
        return 4
    }
    
    func pinViewController(pinViewController: THPinViewController!, isPinValid pin: String!) -> Bool {
        return selectedEmployee?.pinCode == pin
    }
    
    func pinViewControllerDidDismissAfterPinEntryWasSuccessful(pinViewController: THPinViewController!) {
        performSegueWithIdentifier("ServerMap", sender: nil)
    }
    
    func userCanRetryInPinViewController(pinViewController: THPinViewController!) -> Bool {
        return true
    }

}
