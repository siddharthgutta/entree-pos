
import UIKit

class MenuItemsViewController: PFQueryCollectionViewController, UICollectionViewDelegateFlowLayout {

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
        let order = Order()
        order.menuItem = objectAtIndexPath(indexPath)! as! MenuItem
        order.menuItemModifiers = []
        order.notes = ""
        if let splitViewController = navigationController?.splitViewController,
        let partyViewController = splitViewController.viewControllers.first as? PartyViewController {
            order.party = partyViewController.party
        }
        order.seat = 0
        
        order.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) in
            if succeeded {
                self.performSegueWithIdentifier("OrderDetail", sender: order)
            } else {
                fatalError(error!.localizedDescription)
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
