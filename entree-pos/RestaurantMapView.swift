
import UIKit

protocol RestaurantMapViewDataSource {
    
    func numberOfTablesForRestaurantMapView(restaurantMapView: RestaurantMapView) -> Int
    func restaurantMapView(restaurantMapView: RestaurantMapView, imageViewForTableAtIndex index: Int) -> UIImageView
    
}

protocol RestaurantMapViewDelegate {
    
    func restaurantMapView(restaurantMapView: RestaurantMapView, tappedTableAtIndex index: Int)
    
}

class RestaurantMapView: UIView {

    var dataSource: RestaurantMapViewDataSource?
    var delegate: RestaurantMapViewDelegate?
    
    func reloadData() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        if let numberOfTables = dataSource?.numberOfTablesForRestaurantMapView(self) {
            for index in 0..<numberOfTables {
                if let imageView = dataSource?.restaurantMapView(self, imageViewForTableAtIndex: index) {
                    addSubview(imageView)
                }
            }
        }
    }
    
    func subviewTapped(gestureRecognizer: UIGestureRecognizer) {
        let index = subviews.indexOf(gestureRecognizer.view!)
        delegate?.restaurantMapView(self, tappedTableAtIndex: index!)
    }
    
}
