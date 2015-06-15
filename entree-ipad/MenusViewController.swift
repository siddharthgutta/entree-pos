
import UIKit

class MenusViewController: PFQueryCollectionViewController {
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = Menu.query()!
        
        query.whereKey("restaurants", equalTo: Restaurant.sharedRestaurant())
        
        return query
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFCollectionViewCell? {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PFCollectionViewCell
        
        let menu = object! as! Menu
        
        cell.backgroundColor = UIColor.entreeColorForIndex(menu.colorIndex)
        
        cell.textLabel.text = menu.name
        cell.textLabel.textAlignment = .Center
        cell.textLabel.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    // MARK: - UIViewController
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "MenuCategories":
            if let menuCategoriesViewController = segue.destinationViewController as? MenuCategoriesViewController {
                menuCategoriesViewController.menu = sender as! Menu
            }
        default:
            fatalError(UNRECOGNIZED_SEGUE_IDENTIFIER_ERROR_MESSAGE)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println(view.frame.size.width)
        
        loadObjects()
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MenuCategories", sender: objectAtIndexPath(indexPath))
    }
    
}
