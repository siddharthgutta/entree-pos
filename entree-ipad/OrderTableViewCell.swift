
import UIKit

class OrderTableViewCell: UITableViewCell {

    var menuItemNameLabel: UILabel? { return viewWithTag(100) as? UILabel }
    var notesLabel: UILabel? { return viewWithTag(200) as? UILabel }
    var priceLabel: UILabel? { return viewWithTag(300) as? UILabel }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: (128.0 / 255.0), blue: 1, alpha: 0.25)
        selectedBackgroundView = view
    }
    
}
