
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
                    let imageView = UIImageView(frame: CGRectMake(CGFloat(table.x), CGFloat(table.y), 64, 64))
                    imageView.backgroundColor = UIColor.blackColor()
                    addSubview(imageView)
                }
            }
        }
    }
    
}
