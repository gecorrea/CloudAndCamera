import Foundation
import Firebase
import Alamofire

protocol RefreshViewDelegate {
    func refreshView()
    
}

class DAO {
    static let sharedInstance = DAO()
    var comments = [Comment]()
    var selectedItemIndex: Int!
    let postRef = Database.database().reference().child("posts")
    var delegate: RefreshViewDelegate?
    
    func retrieveComments(onCompletion: @escaping () -> Void) {
        postRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                for (_, value) in dict {
                    guard let value = value as? [String: Any] else {return}
                    let username = value["user"] as! String
                    let caption = value["caption"] as! String
                    let photoUrl = value["photoUrl"] as! String
                    let newComment = Comment(userString: username, captionString: caption, photoUrlString: photoUrl)
                    self.comments.append(newComment)
                }
            }
            onCompletion()
        }
    }
    
    
    func loadImagePosts() {
        for comment in comments {
        let url = URL(string: comment.photoUrl)
            Alamofire.request(url!).response { response in // method defaults to `.get`
                if let data = response.data {
                    if let photo = UIImage(data: data) {
                        DispatchQueue.main.async {
                            comment.myImage = photo
                            self.delegate?.refreshView()
                        }
                    }
                }
            }
        }
    }
    
    func retrieveNewPost() {
        postRef.observe(.childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String: Any] {
                let username = dict["user"] as! String
                let caption = dict["caption"] as! String
                let photoUrl = dict["photoUrl"] as! String
                let newComment = Comment(userString: username, captionString: caption, photoUrlString: photoUrl)
                self.comments.append(newComment)
                self.loadImagePosts()
            }
        })
    }
    
    func loadPosts() {
        self.delegate?.refreshView()
    }
}
