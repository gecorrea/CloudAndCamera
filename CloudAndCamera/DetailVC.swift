import UIKit

class DetailVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var textFieldTrailingConstraint: NSLayoutConstraint!
    
    var detailImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = detailImage
        imageView.contentMode = .scaleAspectFill
//        self.view.sendSubview(toBack: imageView)
        commentTextField.delegate = self
    }
    
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: 220, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: 220, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration) { () -> Void in
//            self.commentTextField.frame = self.commentTextField.frame.offsetBy(dx: 0, dy: movement + 25)
            self.commentViewBottomConstraint.constant += movement
            if up == true {
                self.textFieldTrailingConstraint.constant += 65
                self.sendButton.isHidden = false
            }
            else {
                self.textFieldTrailingConstraint.constant -= 65
                self.sendButton.isHidden = true
            }
//            self.view.bringSubview(toFront: self.commentTextField)
            self.view.layoutIfNeeded()
        }
        
        
        
//        UIView.beginAnimations("animateTextField", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(moveDuration)
//        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//        
//        UIView.animate(withDuration: 2.0, animations: { () -> Void in
//            self.titleLabel.center.y = self.titleLabel.center.y - 100
//            self.loginButton.center.y = self.loginButton.center.y + 250
//            self.view.backgroundColor = .gray
//            self.picShareToolbar.isHidden = false
//        })
    }
    
    // Handle hiding the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
