
import UIKit

class MenuItemsViewController: PFQueryCollectionViewController {

    var menuCategory: MenuCategory!
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = MenuItem.query()!
        
        query.whereKey("menuCategory", equalTo: menuCategory)
        
        return query
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "OrderDetail":
            if let navigationController = segue.destinationViewController as? UINavigationController,
            let orderDetailViewController = navigationController.viewControllers.first as? OrderDetailViewController {
                orderDetailViewController.order = sender as! Order
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerNib(UINib(nibName: "MenuCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        
        objectsPerPage = 1000
        
        let sideLength = (703.5 - (16 * 6)) / 5
        (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: sideLength, height: sideLength)
        (collectionView?.collectionViewLayout as! UICollectionViewFlowLayout).sectionInset = UIEdgeInsetsMake(16, 16, 16, 16)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = menuCategory.name
        
        loadObjects()
    }

    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MenuCollectionViewCell
        
        let menuItem = objectAtIndexPath(indexPath)! as! MenuItem
        
        cell.imageView.image = UIImage(named: "Icon Map")!.tintedGradientImageWithColor(UIColor.entreeColorForIndex(menuItem.colorIndex))
        
        cell.textLabel.text = menuItem.name
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let order = Order()
        order.menuItem = objectAtIndexPath(indexPath)! as! MenuItem
        order.menuItemModifiers = []
        order.notes = ""
        order.restaurant = Restaurant.sharedRestaurant()
        order.seat = 0
        
        order.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.performSegueWithIdentifier("OrderDetail", sender: order)
            } else {
                fatalError(error!.localizedDescription)
            }
        }
    }
    
}
