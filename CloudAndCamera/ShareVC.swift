import UIKit

class ShareVC: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var shareButtonBottomConstraint: NSLayoutConstraint!
    var shareImage: UIImage!
    var username: String!
    let dataManager = DAO.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = shareImage
        captionTextView.delegate = self
    }
    
    // Move the share button animated
    func moveButton(_ button: UIButton, moveDistance: Int, up: Bool) {
        let moveDuration = 0.25
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration) { () -> Void in
            self.shareButtonBottomConstraint.constant += movement
            self.view.layoutIfNeeded()
        }
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
                    let comment = self.captionTextView.text {
                    self.dataManager.sendDataToDatabase(photoUrl: photoUrl, comment: comment, onSuccess: {
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

extension ShareVC: UITextViewDelegate {
    // Start editing the text view
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveButton(shareButton, moveDistance: 220, up: true)
    }
    
    // Finish editing the text view
    func textViewDidEndEditing(_ textView: UITextView) {
        moveButton(shareButton, moveDistance: 220, up: false)
    }
}
