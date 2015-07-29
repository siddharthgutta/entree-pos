
import UIKit

class TimeClockViewController: PFQueryCollectionViewController, THPinViewControllerDelegate {

    @IBAction func settings(sender: UIBarButtonItem) {
        let settingsViewController = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
        
        presentViewController(settingsViewController, animated: true, completion: nil)
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    let numberOfCellsPerRow: CGFloat = 5
    let sectionEdgeInsets: CGFloat = 16
    
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
        
        presentViewController(pinViewController, animated: true, completion: nil)
        
        let popover = pinViewController.popoverPresentationController!
        popover.backgroundColor = UIColor.entreeBlueColor()
        popover.permittedArrowDirections = .Left | .Right
        popover.sourceRect = cell.contentView.bounds
        popover.sourceView = cell.contentView
    }
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = Employee.query()!
        
        query.includeKey("currentShift")
        
        query.orderByAscending("name")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            query.whereKey("role", equalTo: "Server")
        } else {
            query.whereKey("role", notEqualTo: "Server")
        }
        
        query.whereKey("restaurant", equalTo: Restaurant.defaultRestaurant()!)
        
        return query
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let user = PFUser.currentUser() {
            
        } else {
            let signInViewController = UIStoryboard(name: "SignIn", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! SignInViewController
            presentViewController(signInViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView!.registerNib(UINib(nibName: "ShadedImageCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
 
        segmentedControl.addTarget(self, action: Selector("loadObjects"), forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadObjects()
    }
    
    // MARK: - THPinViewControllerDelegate
    
    func pinLengthForPinViewController(pinViewController: THPinViewController!) -> UInt {
        return 4
    }
    
    func pinViewController(pinViewController: THPinViewController!, isPinValid pin: String!) -> Bool {
        return selectedEmployee?.pinCode == pin
    }
    
    func pinViewControllerDidDismissAfterPinEntryWasSuccessful(pinViewController: THPinViewController!) {
        if selectedEmployee?.currentShift != nil {
            performSegueWithIdentifier("ServerMap", sender: nil)
        } else {
            let shift = Shift()
            shift.employee = selectedEmployee!
            shift.startedAt = NSDate()
            
            selectedEmployee?.currentShift = shift
            
            PFObject.saveAllInBackground([shift, selectedEmployee!]) { (succeeded: Bool, error: NSError?) in
                if succeeded {
                    self.loadObjects()
                } else {
                    fatalError(error!.description)
                }
            }
        }
    }
    
    func userCanRetryInPinViewController(pinViewController: THPinViewController!) -> Bool {
        return true
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ShadedImageCollectionViewCell
        
        let employee = objectAtIndexPath(indexPath)! as! Employee
        
        cell.imageView.image = nil
        
        if let avatar = avatarCache[employee.objectId!] {
            cell.imageView.image = avatar
        }
        
        if let avatarFile = employee.avatarFile {
            avatarFile.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) in
                if let imageData: NSData = data, let avatar = UIImage(data: imageData) {
                    self.avatarCache[employee.objectId!] = avatar
                    
                    cell.imageView.image = avatar
                    
                    cell.setNeedsDisplay()
                } else {
                    println(error)
                    
                    cell.imageView.backgroundColor = UIColor.darkGrayColor()
                }
            }
        } else {
            cell.imageView.backgroundColor = UIColor.darkGrayColor()
        }
        
        cell.textLabel.text = employee.name
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
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedEmployee = objectAtIndexPath(indexPath) as? Employee
        
        if selectedEmployee?.currentShift != nil {
            presentPinViewControllerFromCollectionViewCell(collectionView.cellForItemAtIndexPath(indexPath)!)
        } else {
            let alertController = UIAlertController(title: "You must clock-in", message: "Please clock-in before accessing your tables", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Clock-in", style: .Default) { (action: UIAlertAction!) in
                self.presentPinViewControllerFromCollectionViewCell(collectionView.cellForItemAtIndexPath(indexPath)!)
            })

            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionEdgeInsets, left: sectionEdgeInsets, bottom: sectionEdgeInsets, right: sectionEdgeInsets)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let sideLength = (collectionView.bounds.width - ((numberOfCellsPerRow + 1) * sectionEdgeInsets)) / numberOfCellsPerRow
        return CGSize(width: sideLength, height: sideLength)
    }
    
}
