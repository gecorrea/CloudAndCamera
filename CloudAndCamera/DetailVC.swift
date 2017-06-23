import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldTrailingConstraint: NSLayoutConstraint!
    var detailImage: UIImage!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentView: UIView!
    let dataManager = DAO.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubview(toFront: commentView)
        imageView.image = detailImage
        commentTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        setNumberOfLikesText()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataManager.delegate = self
        dataManager.loadPosts()
    }
    
    // Move the text field animated
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.25
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.animate(withDuration: moveDuration) { () -> Void in
            self.commentViewBottomConstraint.constant += movement
            self.textFieldTrailingConstraint.constant += (up ? 65 : -65)
            self.sendButton.isHidden = up ? false : true
            self.view.layoutIfNeeded()
        }
    }
    
    // Handle hiding the keyboard.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func likeButtonPushed(_ sender: Any) {
        dataManager.handleLikes {
            self.setNumberOfLikesText()
        }
    }
    
    func setNumberOfLikesText() {
        dataManager.posts[dataManager.selectedItemIndex].likelabel == true ? likeButton.setImage(UIImage(named: "active_like"), for: .normal) : likeButton.setImage(UIImage(named: "icn_like"), for: .normal)
        likesLabel.text = dataManager.posts[dataManager.selectedItemIndex].likeCount == 1 ? "\(dataManager.posts[dataManager.selectedItemIndex].likeCount) like" : "\(dataManager.posts[dataManager.selectedItemIndex].likeCount) likes"
    }
}

extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CustomTableViewCell
//        if dataManager.numberOfComments == 0 {
            cell.userName.text = dataManager.posts[dataManager.selectedItemIndex].user
            cell.comment.text = dataManager.posts[dataManager.selectedItemIndex].caption
//            dataManager.numberOfComments += 1
//        }
//        else {
//            
//        }
        
        return cell
    }
}

extension DetailVC: UITableViewDelegate {
    
}

extension DetailVC: UITextFieldDelegate {
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
}

extension DetailVC: RefreshViewDelegate {
    func refreshView() {
        self.tableView.reloadData()
    }
}
