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
    
// MARK: Methods for CollectionVC
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
    
    
    func loadImagePosts(onSuccess: @escaping () -> Void) {
        for comment in comments {
        let url = URL(string: comment.photoUrl)
            Alamofire.request(url!).response { response in // method defaults to `.get`
                if let data = response.data {
                    if let photo = UIImage(data: data) {
                        //DispatchQueue.main.async {
                            comment.myImage = photo
                        
                        //}
                    }
                }
                onSuccess()
            }
        }
    }


//    func retrieveNewPost() {
//        postRef.observe(.childAdded, with: {(snapshot) -> Void in
//            if let dict = snapshot.value as? [String: Any] {
//                let username = dict["user"] as! String
//                let caption = dict["caption"] as! String
//                let photoUrl = dict["photoUrl"] as! String
//                let newComment = Comment(userString: username, captionString: caption, photoUrlString: photoUrl)
//                self.comments.append(newComment)
//                self.loadImagePosts()
//            }
//        })
//    }
   
// MARK: Methods for DetailVC
    func loadPosts() {
        self.delegate?.refreshView()
    }
    
// MARK: Methods for ShareVC
    func storeImage(imageData: Data, onError: @escaping (_ errorMessage: String?) -> Void, onSuccess: @escaping (StorageMetadata) -> Void) {
        let photoIDString = NSUUID().uuidString
        let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("posts").child(photoIDString)
        storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                onError(error?.localizedDescription)
                return
            }
            onSuccess(metadata!)
        })
    }
    
    func sendDataToDatabase(photoUrl: String, caption: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let uID = Auth.auth().currentUser!.uid
        
        var username = String()
        let ref = Database.database().reference()
        
        ref.child("users").child(uID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            username = value?["username"] as? String ?? ""
            //            print(username)
            
            let postsRef = ref.child("posts")
            let newPostID = postsRef.childByAutoId().key
            let newPostRef = postsRef.child(newPostID)
            newPostRef.setValue(["photoUrl": photoUrl, "caption": caption, "user": username]) { (error, ref) in
                if error != nil {
                    onError(error?.localizedDescription)
                    return
                }
                onSuccess()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
