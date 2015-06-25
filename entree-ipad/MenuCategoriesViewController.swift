
import UIKit

class MenuCategoriesViewController: PFQueryCollectionViewController {
    
    var menu: Menu!
    
    // MARK: - PFQueryCollectionViewController
    
    override func queryForCollection() -> PFQuery {
        let query = MenuCategory.query()!
        
        query.whereKey("menu", equalTo: menu)
        
        return query
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
        
        navigationItem.title = menu.name
        
        loadObjects()
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! MenuCollectionViewCell
        
        let menuCategory = objectAtIndexPath(indexPath)! as! MenuCategory
        
        cell.imageView.image = UIImage(named: "IconMap-\(menuCategory.colorIndex)")!
        
        cell.textLabel.text = menuCategory.name
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MenuItems", sender: objectAtIndexPath(indexPath))
    }
    
}