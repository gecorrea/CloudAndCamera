import UIKit
import FirebaseStorage
import FirebaseDatabase

class ShareVC: UIViewController {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var shareImage: UIImage!
    

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
            let photoIDString = NSUUID().uuidString
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIDString)
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                if let photoUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendDataToDatabase(photoUrl: photoUrl)
                }
            })
        }
        else {
            ProgressHUD.showError("Please set a profile image.")
            
        }
    }
    
    func sendDataToDatabase(photoUrl: String) {
        let ref = Database.database().reference()
        let postsRef = ref.child("posts")
        let newPostID = postsRef.childByAutoId().key
        let newPostRef = postsRef.child(newPostID)
        newPostRef.setValue(["photoUrl": photoUrl, "caption": captionTextView.text!]) { (error, ref) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Thanks for sharing a post!")
            self.shareImage = nil
            self.navigationController?.popViewController(animated: true)
            self.tabBarController?.selectedIndex = 0
        }
    }
    
}
