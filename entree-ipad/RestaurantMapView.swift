
import UIKit

protocol RestaurantMapViewDataSource {
    
    func numberOfTablesForRestaurantMapView(restaurantMapView: RestaurantMapView) -> Int
    func restaurantMapView(restaurantMapView: RestaurantMapView, tableAtIndex index: Int) -> Table
    
}

protocol RestaurantMapViewDelegate {
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tappedTableAtIndex index: Int)
    
}

class RestaurantMapView: UIView {

    var dataSource: RestaurantMapViewDataSource?
    var delegate: RestaurantMapViewDelegate?
    
    func reloadData() {
        for subview in subviews as! [UIView] {
            subview.removeFromSuperview()
        }
        
        if let numberOfTables = dataSource?.numberOfTablesForRestaurantMapView(self) {
            for index in 0..<numberOfTables {
                if let table = dataSource?.restaurantMapView(self, tableAtIndex: index) {
                    let status = table.currentParty != nil ? "Occupied" : "Available"
                    
                    let image = UIImage(named: "Table-\(table.type)")!
                    
                    let imageView = UIImageView(frame: CGRectMake(CGFloat(table.x), CGFloat(table.y), image.size.width, image.size.height))
                    imageView.image = image
                    imageView.userInteractionEnabled = true
                    
                    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("subviewTapped:")))
                    
                    addSubview(imageView)
                }
            }
        }
    }
    
    func subviewTapped(gestureRecognizer: UIGestureRecognizer) {
        let index = find(subviews as! [UIView], gestureRecognizer.view!)!
        delegate?.restaurantMapView(self, tappedTableAtIndex: index)
    }
    
}
