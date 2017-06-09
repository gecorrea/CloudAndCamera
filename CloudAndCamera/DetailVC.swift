import UIKit

class DetailVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldTrailingConstraint: NSLayoutConstraint!
    var detailImage: UIImage!
    var comments = ["1"]
    @IBOutlet weak var likeButton: UIButton!
    var numberOfLikes = 0
    @IBOutlet weak var likesLabel: UILabel!
    var imageName = "icn_like"
    @IBOutlet weak var commentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubview(toFront: commentView)
    

        imageView.image = detailImage
        imageView.contentMode = .scaleAspectFill
        commentTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        likesLabel.text = "\(numberOfLikes) likes"
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
    
    // Move the text field animated
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration) { () -> Void in
            self.commentViewBottomConstraint.constant += movement
            if up == true {
                self.textFieldTrailingConstraint.constant += 65
                self.sendButton.isHidden = false
            }
            else {
                self.textFieldTrailingConstraint.constant -= 65
                self.sendButton.isHidden = true
            }
            self.view.layoutIfNeeded()
        }

    }
    
    // Handle hiding the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CustomTableViewCell
        cell.userName.text = "Name"
        cell.comment.text = "Say something."
        
        return cell
    }

    @IBAction func likeButtonPushed(_ sender: Any) {
        if (imageName.isEqual( "icn_like"))  {
            likeButton.setImage(UIImage(named: "active_like"), for: .normal)
            imageName = "active"
            numberOfLikes += 1
            setNumberOfLikesText()
        }
        else {
            likeButton.setImage(UIImage(named: "icn_like"), for: .normal)
            imageName = "icn_like"
            numberOfLikes -= 1
            setNumberOfLikesText()
        }
    }
    
    func setNumberOfLikesText() {
        if numberOfLikes == 1 {
            likesLabel.text = "\(numberOfLikes) like"
        }
        else {
            likesLabel.text = "\(numberOfLikes) likes"
        }
    }
}
