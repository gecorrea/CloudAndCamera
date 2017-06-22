import UIKit

class ShareVC: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var shareImage: UIImage!
    var username: String!
    let dataManager = DAO.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = shareImage
    }
    
    // Dismiss keyboard if the user touches outside of it.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func shareAction(_ sender: UIButton) {
        ProgressHUD.show("Loading...", interaction: false)
        if let profileImg = self.photo.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            dataManager.storeImage(imageData: imageData, onError: { (error) in
                ProgressHUD.showError(error!)
            }, onSuccess: { (metadata) in
                if let photoUrl = metadata.downloadURL()?.absoluteString,
                    let caption = self.captionTextView.text {
                    self.dataManager.sendDataToDatabase(photoUrl: photoUrl, caption: caption, onSuccess: {
                        ProgressHUD.showSuccess("Thanks for sharing a post!")
                        self.shareImage = nil
                        self.navigationController?.popViewController(animated: true)
                        self.tabBarController?.selectedIndex = 0
                    }, onError: { (error) in
                        ProgressHUD.showError(error!)
                    })
                }
            })
        }
        else {
            ProgressHUD.showError("Please set a profile image.")
        }
    }
}
