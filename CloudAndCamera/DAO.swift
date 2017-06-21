import Foundation
import Firebase

protocol RefreshViewDelegate {
    func refreshView()
    
}

class DAO {
    static let sharedInstance = DAO()
    var comments = [Comment]()
    var images = [UIImage]()
    var postIDKeys = [String]()
    var delegate: RefreshViewDelegate?
    var postIDKey: String!
    
    func retrievePostKeys() {
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            let newKey = snapshot.key
            self.postIDKeys.append(newKey)
        }
    }
    
    func retrieveComments(onCompletion: @escaping (Array<Comment>) -> Void) {
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let username = dict["user"] as! String
                let caption = dict["caption"] as! String
                let photoUrl = dict["photoUrl"] as! String
                let newComment = Comment(userString: username, captionString: caption, photoUrlString: photoUrl)
                self.comments.append(newComment)
            }
            onCompletion(self.comments)
        }
        
       
        
    }
    
    
    func loadImagePosts() {
        for comment in comments {
            let storageRef = Storage.storage().reference(forURL: comment.photoUrl)
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    if let photo = UIImage(data: data!) {
                        DispatchQueue.main.async {
                            self.images.append(photo)
                            self.delegate?.refreshView()
                        }
                    }
                }).resume()
            })
        }
    }
    
    func loadPosts() {
        Database.database().reference().child("posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if snapshot.key == self.postIDKey {
                if let dict = snapshot.value as? [String: Any] {
                    let userText = dict["user"] as! String
                    let captionText = dict["caption"] as! String
                    let photoUrlText = dict["photoUrl"] as! String
                    let post = Comment(userString: userText, captionString: captionText, photoUrlString: photoUrlText)
                    self.comments.append(post)
                    self.delegate?.refreshView()
                }
            }
        }
    }
}
