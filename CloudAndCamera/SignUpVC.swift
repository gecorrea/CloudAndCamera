import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    var validUsername: String!
    var validEmail: String!
    var validPassword: String!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.backgroundColor = UIColor.clear
        userNameTextField.tintColor = UIColor.white
        userNameTextField.textColor = UIColor.white
        userNameTextField.attributedPlaceholder = NSAttributedString(string: userNameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let userNameBottomLayer = CALayer()
        userNameBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        userNameBottomLayer.backgroundColor = UIColor.white.cgColor
        userNameTextField.layer.addSublayer(userNameBottomLayer)

        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let emailBottomLayer = CALayer()
        emailBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        emailBottomLayer.backgroundColor = UIColor.white.cgColor
        emailTextField.layer.addSublayer(emailBottomLayer)
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        let passwordBottomLayer = CALayer()
        passwordBottomLayer.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        passwordBottomLayer.backgroundColor = UIColor.white.cgColor
        passwordTextField.layer.addSublayer(passwordBottomLayer)
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.handleSelectedProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        handleTextField()
    }
    
    func handleTextField() {
        userNameTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpVC.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange () {
        guard let username = userNameTextField.text, !username.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else{
            signUpButton.setTitleColor(UIColor.lightText, for: .normal)
            signUpButton.isEnabled = false
            return
        }
        signUpButton.isEnabled = true
        signUpButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func handleSelectedProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

    @IBAction func alreadyUser(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // Method called when sign up button is pressed.
    @IBAction func signUp(_ sender: UIButton) {
        if let tempUserName = userNameTextField.text {
            self.validUsername = tempUserName
        }
        if let tempEmail = emailTextField.text {
            self.validEmail = tempEmail
        }
        if let tempPassword = passwordTextField.text {
            self.validPassword = tempPassword
        }
        Auth.auth().createUser(withEmail: validEmail, password: validPassword) { (user: User?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            }
            let uid = user?.uid
            let storageRef = Storage.storage().reference(forURL: "gs://cloudandcamera-c76ce.appspot.com").child("profile_image").child(uid!)
            if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
                storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        return
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        self.setUserInfo(profileImageURL: profileImageURL, username: self.validUsername, email: self.validEmail, uid: uid!)
                    }
                })
            }
            
        }
    }
    
    // Save new username, email, and profileImage to firebase storage.
    func setUserInfo (profileImageURL: String, username: String, email: String, uid: String) {
        let ref = Database.database().reference()
        let userRef = ref.child("users")
        let newUserRef = userRef.child(uid)
        newUserRef.setValue(["username": username, "email": email, "profileImageURL": profileImageURL])
        self.performSegue(withIdentifier: "signUpToTabBatVC", sender: nil)
    }
}

// Extension to allow user to choose profile image from photo library.
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
