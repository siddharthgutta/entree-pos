
import UIKit

class ShadedImageCollectionViewCell: PFCollectionViewCell {
    
    @IBOutlet var shadedImageView: UIImageView!
    @IBOutlet var shadeView: UIView!
    @IBOutlet var primaryTextLabel: UILabel!
    @IBOutlet var detailTextLabel: UILabel!
    @IBOutlet var badgeLabel: BadgeLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        shadedImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        shadeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        primaryTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailTextLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        badgeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    }
    
}
