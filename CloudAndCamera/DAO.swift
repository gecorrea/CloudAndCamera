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
    let photoCache = NSCache <AnyObject, AnyObject>()
    var imageName = "icn_like"
    var likes = Dictionary <String, Bool>()
    var likeCount = Int()
    var numberOfComments = 0
    
    
    // MARK: Methods for CollectionVC
    func retrieveComments(onCompletion: @escaping () -> Void) {
        postRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let key = snapshot.key
            if let dict = snapshot.value as? [String: Any] {
                for (_, value) in dict {
                    guard let value = value as? [String: Any] else {return}
                    let username = value["user"] as! String
                    let caption = value["caption"] as! String
                    let photoUrl = value["photoUrl"] as! String
                    let newComment = Comment(userString: username, captionString: caption, photoUrlString: photoUrl, keyString: key)
                    self.comments.append(newComment)
                }
            }
            onCompletion()
        }
    }
    
    func loadImagePosts(onSuccess: @escaping () -> Void) {
        for comment in comments {
            let url = URL(string: comment.photoUrl)
            // Load photo from cache if it is there.
            if let photoFromCache = photoCache.object(forKey: comment.photoUrl as AnyObject) as? UIImage {
                comment.myImage = photoFromCache
                onSuccess()
            }
            Alamofire.request(url!).response { response in // method defaults to `.get`
                if let data = response.data {
                    if let photo = UIImage(data: data) {
                        // Add photo to cache.
                        let photoToCache = photo
                        self.photoCache.setObject(photoToCache, forKey: comment.photoUrl as AnyObject)
                        comment.myImage = photoToCache
                    }
                }
                onSuccess()
            }
        }
    }
    
    
    // MARK: Methods for DetailVC
    func loadPosts() {
        self.delegate?.refreshView()
    }
    
    func handleLikes(photoUrl: String) {
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                
                self.likes = post["likes"] as? [String : Bool] ?? [:]
                self.likeCount = post["likeCount"] as? Int ?? 0
                if let _ = self.likes[uid] {
                    // Unstar the post and remove self from stars
                    self.likeCount -= 1
                    self.likes.removeValue(forKey: uid)
                    self.imageName = "icn_like"
                } else {
                    // Star the post and add self to stars
                    self.likeCount += 1
                    self.likes[uid] = true
                    self.imageName = "active"
                }
                post["likeCount"] = self.likeCount as AnyObject?
                post["likes"] = self.likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
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
