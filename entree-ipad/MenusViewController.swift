
import UIKit

class MenusViewController: PFQueryCollectionViewController {
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = Menu.query()!
        
        query.whereKey("restaurants", equalTo: Restaurant.sharedRestaurant())
        
        return query
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
        
        loadObjects()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MenuCollectionViewCell
        
        let menu = objectAtIndexPath(indexPath)! as! Menu
        
        cell.imageView.image = UIImage(named: "IconMap-\(menu.colorIndex)")!
        
        cell.textLabel.text = menu.name
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MenuCategories", sender: objectAtIndexPath(indexPath))
    }
    
}
