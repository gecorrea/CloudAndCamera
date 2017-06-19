import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    var validEmail: String!
    var validPassword: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        signInButton.isEnabled = false
        handleTextField()
    }
    
    // Dismiss keyboard if the user touches outside of it.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // If the user does not log out, they will automatically login the next time they open the app.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "signInToTabBarVC", sender: nil)
        }
    }
    
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange () {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else{
                signInButton.setTitleColor(UIColor.lightText, for: .normal)
                signInButton.isEnabled = false
                return
        }
        signInButton.isEnabled = true
        signInButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    // Method called when sign in button is pressed.
    @IBAction func signIn(_ sender: UIButton) {
        view.endEditing(true)
        if let tempEmail = emailTextField.text {
            self.validEmail = tempEmail
        }
        if let tempPassword = passwordTextField.text {
            self.validPassword = tempPassword
        }
        ProgressHUD.show("Please wait...", interaction: false)
        AuthServices.signIn(email: validEmail, password: validPassword, onSuccess: {
            ProgressHUD.showSuccess("Welcome!")
            self.performSegue(withIdentifier: "signInToTabBarVC", sender: nil)
        }, onError: {error in
            ProgressHUD.showError(error!)
        })
    }
}
