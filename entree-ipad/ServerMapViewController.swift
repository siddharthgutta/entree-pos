
import UIKit

class ServerMapViewController: UIViewController, RestaurantMapViewDataSource, RestaurantMapViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    
    let restaurantMapView = RestaurantMapView()
    
    var employee: Employee!
    var tables = [Table]()
    
    // MARK: - ServerMapViewController
    
    private func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = restaurantMapView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = ((boundsSize.height - 64.0) - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }

        restaurantMapView.frame = contentsFrame
    }
    
    func loadTables() {
        let query = Table.query()!
        
        query.includeKey("currentParty")
        query.includeKey("currentParty.table")
        
        query.whereKey("restaurant", equalTo: Restaurant.sharedRestaurant())
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) in
            if let tables = objects as? [Table] {
                self.tables = tables
                
                self.restaurantMapView.reloadData()
            } else {
                fatalError(error!.localizedDescription)
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
        case "Party":
            if let partyViewController = segue.destinationViewController as? PartyViewController {
                partyViewController.party = sender as! Party
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        restaurantMapView.dataSource = self
        restaurantMapView.delegate = self
        restaurantMapView.bounds.size = CGSizeMake(600, 600)
        
        scrollView.addSubview(restaurantMapView)
        
        scrollView.contentSize = restaurantMapView.bounds.size
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = minScale;
        
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale
        
        centerScrollViewContents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = employee.name + " – \(employee.activePartyCount) active tables"
        
        loadTables()
    }
    
    // MARK: - RestaurantMapViewDataSource
    
    func numberOfTablesForRestaurantMapView(restaurantMapView: RestaurantMapView) -> Int {
        return tables.count
    }
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tableAtIndex index: Int) -> Table {
        return tables[index]
    }
    
    // MARK: - RestaurantMapViewDelegate
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tappedTableAtIndex index: Int) {
        if let party = tables[index].currentParty {
            performSegueWithIdentifier("Party", sender: party)
        } else {
            // TODO: Add handling for when a table is not occupied (Currently always :P)
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
