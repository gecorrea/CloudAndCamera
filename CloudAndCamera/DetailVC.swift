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
    @IBOutlet weak var deleteButton: UIButton!
    let dataManager = DAO.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.bringSubview(toFront: commentView)
        imageView.image = detailImage
        commentTextField.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        setNumberOfLikesText()
        dataManager.getCurrentUser {self.statusOfDeleteButton()}
    }
    
    func statusOfDeleteButton() {
        deleteButton.isEnabled  = dataManager.posts[dataManager.selectedItemIndex].users.first == dataManager.currentUser ? true : false
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

    @IBAction func sendButtonPushed(_ sender: UIButton) {
        let validateText = commentTextField.text?.replacingOccurrences(of: " ", with: "")
        if validateText == "" {
            ProgressHUD.showError("Comment must contain atleast one character that is not a space.")
        } else {
            if let postText = commentTextField.text{
                dataManager.postComment(user: dataManager.currentUser,userPost: postText, onCompletion: {
                    self.tableView.reloadData()
                })
            }
        }
        self.view.endEditing(true)
        commentTextField.text = ""
    }
    
    @IBAction func commentsButtonPushed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let tableViewVC = storyboard.instantiateViewController(withIdentifier: "TableViewVC") as! TableViewVC
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(tableViewVC, animated: true)
    }
    
    @IBAction func deleteButtonPushed(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this post? This action cannot be undone.", preferredStyle: .actionSheet)
        
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.dataManager.deletePost {
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
}

extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.posts[dataManager.selectedItemIndex].commentCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CustomTableViewCell
        cell.userName.text = dataManager.posts[dataManager.selectedItemIndex].users[indexPath.row]
        cell.comment.text = dataManager.posts[dataManager.selectedItemIndex].comments[indexPath.row]
        return cell
    }
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
