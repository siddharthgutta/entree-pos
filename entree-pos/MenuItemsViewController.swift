
import UIKit

class MenuItemsViewController: PFQueryCollectionViewController {

    var menuCategory: MenuCategory!
    
    let numberOfCellsPerRow: CGFloat = 4
    let sectionEdgeInsets: CGFloat = 16
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = MenuItem.query()!
        
        query.includeKey("menuCategory.menu")
        
        query.whereKey("menuCategory", equalTo: menuCategory)
        
        return query
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OrderDetail" {
            if let navigationController = segue.destinationViewController as? UINavigationController,
                let orderItemDetailViewController = navigationController.viewControllers.first as? OrderItemDetailViewController {
                    orderItemDetailViewController.orderItem = sender as! OrderItem
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerNib(UINib(nibName: "MenuCollectionViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: "Cell")
        
        objectsPerPage = 1000
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
        
        cell.imageView.image = UIImage(named: "IconMap-\(menuItem.colorIndex)")!
        
        cell.textLabel.text = menuItem.name
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let orderItem = OrderItem()
        orderItem.menuItem = objectAtIndexPath(indexPath) as! MenuItem
        orderItem.menuItemModifiers = []
        orderItem.notes = ""
        orderItem.seatNumber = 0
        
        let navigationController = splitViewController?.viewControllers.first as! UINavigationController
        if let orderItemsViewController = navigationController.viewControllers.first as? OrderItemsViewController {
            let party =  orderItemsViewController.party
            orderItem.party = party
            
            orderItem.saveInBackgroundWithBlock {
                (succeeded, error) in
                
                if succeeded {
                    self.performSegueWithIdentifier("OrderDetail", sender: orderItem)
                } else {
                    print(error!.localizedDescription)
                }
            }
        } else if let quickServiceOrderViewController = navigationController.viewControllers.first as? QuickServiceOrderViewController {
            quickServiceOrderViewController.order.orderItems.append(orderItem)
            orderItem.order = quickServiceOrderViewController.order
            
            PFObject.saveAllInBackground([orderItem, quickServiceOrderViewController.order]) {
                (succeeded, error) in
                
                if succeeded {
                    let navController = UIStoryboard(name: "OrderItemDetail", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as! UINavigationController
                    let quickServiceOrderItemDetailViewController = navController.viewControllers.first as! QuickServiceOrderItemDetailViewController
                    quickServiceOrderItemDetailViewController.orderItem = orderItem
                    
                    navController.modalPresentationStyle = .FormSheet
                    self.presentViewController(navController, animated: true, completion: nil)
                } else {
                    self.presentViewController(UIAlertController.alertControllerForError(error!), animated: true, completion: nil)
                }
            }
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
