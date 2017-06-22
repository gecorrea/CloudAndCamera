import UIKit

class DetailVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, RefreshViewDelegate {

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
    var numberOfCells = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.delegate = self
        dataManager.loadPosts()
        self.view.bringSubview(toFront: commentView)
        imageView.image = detailImage
        commentTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        likesLabel.text = "\(dataManager.numberOfLikes) likes"
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
        let moveDuration = 0.25
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

    @IBAction func likeButtonPushed(_ sender: Any) {
        if (dataManager.imageName.isEqual( "icn_like"))  {
            likeButton.setImage(UIImage(named: "active_like"), for: .normal)
            dataManager.likePhoto()
        }
        else {
            likeButton.setImage(UIImage(named: "icn_like"), for: .normal)
            dataManager.unlikePhoto()
        }
        setNumberOfLikesText()
    }
    
    func setNumberOfLikesText() {
        if dataManager.numberOfLikes == 1 {
            likesLabel.text = "\(dataManager.numberOfLikes) like"
        }
        else {
            likesLabel.text = "\(dataManager.numberOfLikes) likes"
        }
    }
    
    func refreshView() {
        self.tableView.reloadData()
    }
}

extension DetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CustomTableViewCell
        if dataManager.numberOfComments == 0 {
            cell.userName.text = dataManager.comments[dataManager.selectedItemIndex].user
            cell.comment.text = dataManager.comments[dataManager.selectedItemIndex].caption
            dataManager.numberOfComments += 1
        }
        else {
            
        }
        
        return cell
    }
}
