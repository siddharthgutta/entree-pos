
import UIKit

class ServerMapViewController: UIViewController, RestaurantMapViewDataSource, RestaurantMapViewDelegate, UIScrollViewDelegate {
    
    @IBAction func newOrder(sender: UIBarButtonItem) {
        let order = Order()
        
        order.installation = PFInstallation.currentInstallation()
        order.restaurant = Restaurant.defaultRestaurantFromLocalDatastoreFetchIfNil()!
        order.type = "Quick Service"
        
        order.orderItems = []
        
        order.server = employee
        
        order.saveInBackgroundWithBlock {
            (succeeded, error) in
            
            if succeeded {
                let quickServiceRootViewController = UIStoryboard(name: "QuickService", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UISplitViewController
                let navController = quickServiceRootViewController.viewControllers.first as! UINavigationController
                let quickServiceOrderViewController = navController.viewControllers.first as! QuickServiceOrderViewController
                quickServiceOrderViewController.order = order
                self.presentViewController(quickServiceRootViewController, animated: true, completion: nil)
            } else {
                self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
            }
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    
    let restaurantMapView = RestaurantMapView()
    
    var employee: Employee!
    var tables = [Table]()
    
    // MARK: - ServerMapViewController
    
    private func centerScrollViewContents() {
        let scrollViewBoundsSize = scrollView.bounds.size
        var mapViewFrame = restaurantMapView.frame
        
        if mapViewFrame.size.width < scrollViewBoundsSize.width {
            mapViewFrame.origin.x = (scrollViewBoundsSize.width - mapViewFrame.size.width) / 2.0
        } else {
            mapViewFrame.origin.x = 0
        }
        
        if mapViewFrame.size.height < scrollViewBoundsSize.height {
            mapViewFrame.origin.y = ((scrollViewBoundsSize.height - 64.0) - mapViewFrame.size.height) / 2.0
        } else {
            mapViewFrame.origin.y = 0
        }
        
        restaurantMapView.frame = mapViewFrame
    }
    
    func loadTablesWithCompletion(completion: ((Void) -> (Void))?) {
        let query = Table.query()!
        
        query.includeKey("currentParty")
        query.includeKey("currentParty.table")
        
        query.whereKey("restaurant", equalTo: Restaurant.defaultRestaurantWithoutData()!)
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) in
            if let tables = objects as? [Table] {
                self.tables = tables
                
                self.restaurantMapView.reloadData()
                
                completion?()
            } else {
                println(error?.localizedDescription)
            }
        }
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "EmployeeClock":
            if let employeeClockViewController = segue.destinationViewController as? EmployeeClockViewController {
                employeeClockViewController.employee = employee
            }
        case "Overview":
            if let navigationController = segue.destinationViewController as? UINavigationController,
            let serverOverviewViewController = navigationController.viewControllers.first as? ServerOverviewViewController {
                serverOverviewViewController.server = employee
            }
        case "Party":
            if let splitViewController = segue.destinationViewController as? UISplitViewController,
            let navigationController = splitViewController.viewControllers.first as? UINavigationController,
            let orderItemsViewController = navigationController.viewControllers.first as? OrderItemsViewController {
                orderItemsViewController.party = sender as! Party
            }
        case "CustomerTabs":
            let navController = segue.destinationViewController as! UINavigationController
            let customerTabsViewController = navController.viewControllers.first as! CustomerTabsViewController
            customerTabsViewController.server = employee
        default:
            println("Unrecognized segue identifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        restaurantMapView.dataSource = self
        restaurantMapView.delegate = self
        restaurantMapView.bounds.size = view.bounds.size
        
        scrollView.addSubview(restaurantMapView)
        
        scrollView.contentSize = restaurantMapView.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = 0.9 // minScale
        
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale
        
        centerScrollViewContents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "\(employee.name) – \(employee.activePartyCount) Active Tables"
        
        loadTablesWithCompletion {
            self.centerScrollViewContents()
        }
    }
    
    // MARK: - RestaurantMapViewDataSource
    
    func numberOfTablesForRestaurantMapView(restaurantMapView: RestaurantMapView) -> Int {
        return tables.count
    }
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, imageViewForTableAtIndex index: Int) -> UIImageView {
        let table = tables[index]
        
        let imageTintColor: UIColor
        if table.currentParty == nil {
            imageTintColor = UIColor.lightGrayColor()
        } else if table.currentParty!.server.hasSameObjectIDAs(employee) {
            imageTintColor = UIColor.entreeBlueColor()
        } else {
            imageTintColor = UIColor.darkGrayColor()
        }
        
        let image = UIImage(named: "Table-\(table.type)")!.tintedGradientImageWithColor(imageTintColor)
        
        let imageView = UIImageView(frame: CGRectMake(table.x, table.y, image.size.width, image.size.height))
        imageView.image = image
        imageView.userInteractionEnabled = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: restaurantMapView, action: Selector("subviewTapped:"))
        tapGestureRecognizer.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        return imageView
    }
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tableAtIndex index: Int) -> Table {
        return tables[index]
    }
    
    // MARK: - RestaurantMapViewDelegate
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tappedTableAtIndex index: Int) {
        if let party = tables[index].currentParty {
            if party.server.hasSameObjectIDAs(employee) {
                performSegueWithIdentifier("Party", sender: party)
            } else {
                let alertController = UIAlertController(title: "Oops!", message: "Sorry, you do not have access to this table.", preferredStyle: .Alert)
                
                alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        } else {
            let addPartyAlertController = UIAlertController(title: "Add Party", message: nil, preferredStyle: .Alert)
            
            addPartyAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.placeholder = "Name (Optional)"
            }
            
            addPartyAlertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
                textField.placeholder = "Size (Optional)"
                textField.keyboardType = .NumberPad
            }
            
            addPartyAlertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            addPartyAlertController.addAction(UIAlertAction(title: "Add", style: .Default) { (action: UIAlertAction!) in
                let party = Party()
                party.arrivedAt = NSDate()
                party.name = (addPartyAlertController.textFields?.first as! UITextField).text
                party.restaurant = Restaurant.defaultRestaurantWithoutData()!
                party.seatedAt = NSDate()
                party.server = self.employee
                party.size = (addPartyAlertController.textFields?.last as! UITextField).text.intValue
                party.table = self.tables[index]
                
                self.tables[index].currentParty = party
                
                self.employee.incrementKey("activePartyCount")
                
                PFObject.saveAllInBackground([party, self.tables[index], self.employee]) { (succeeded: Bool, error: NSError?) in
                    if succeeded {
                        self.loadTablesWithCompletion(nil)
                    } else {
                        println(error?.localizedDescription)
                    }
                }
            })
            
            presentViewController(addPartyAlertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return restaurantMapView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
}
