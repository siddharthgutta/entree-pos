
import UIKit

class ShadedImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var detailTextLabel: UILabel!
    @IBOutlet var badgeLabel: BadgeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        overlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        badgeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
}
