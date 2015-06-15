
import UIKit

class MenuCategoriesViewController: PFQueryCollectionViewController {
    
    var menu: Menu!
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = MenuCategory.query()!
        
        query.whereKey("menu", equalTo: menu)
        
        return query
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PFCollectionViewCell
        
        let menuCategory = object! as! MenuCategory
        
        cell.backgroundColor = UIColor.entreeColorForIndex(menuCategory.colorIndex)
        
        cell.textLabel.text = menuCategory.name
        cell.textLabel.textAlignment = .Center
        cell.textLabel.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "MenuItems":
            if let menuItemsViewController = segue.destinationViewController as? MenuItemsViewController {
                menuItemsViewController.menuCategory = sender as! MenuCategory
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = menu.name
        
        loadObjects()
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MenuItems", sender: objectAtIndexPath(indexPath))
    }
    
}