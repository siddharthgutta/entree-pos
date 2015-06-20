
import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

}
