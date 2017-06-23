import Foundation
import Firebase
import Alamofire

protocol RefreshViewDelegate {
    func refreshView()
}

class DAO {
    static let sharedInstance = DAO()
    var posts = [Post]()
    var selectedItemIndex: Int!
    let postRef = Database.database().reference().child("posts")
    var delegate: RefreshViewDelegate?
    let photoCache = NSCache <AnyObject, AnyObject>()
    var numberOfComments = 0
    
    
    // MARK: Methods for CollectionVC
    func retrieveComments(onCompletion: @escaping () -> Void) {
        postRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any], let uid = Auth.auth().currentUser?.uid {
                for (_, value) in dict {
                    guard let value = value as? [String: Any] else {return}
                    let postKey = value["post_key"] as! String
                    let username = value["user"] as! String
                    let caption = value["caption"] as! String
                    let photoUrl = value["photoUrl"] as! String
                    let likeCount = value["likeCount"] as! Int
                    let likeLabelDict = value["likes"] as? [String : Bool]
                    let newPost = Post(postKeyString: postKey, userString: username, captionString: caption, photoUrlString: photoUrl, likeNumber: likeCount)
                    if let valueLikeLabel = likeLabelDict?[uid] {
                        newPost.likelabel = valueLikeLabel
                    }
                    self.posts.append(newPost)
                }
            }
            onCompletion()
        }
    }
    
    func loadImagePosts(onSuccess: @escaping () -> Void) {
        for post in posts {
            let url = URL(string: post.photoUrl)
            // Load photo from cache if it is there.
            if let photoFromCache = photoCache.object(forKey: post.photoUrl as AnyObject) as? UIImage {
                post.myImage = photoFromCache
                onSuccess()
            }
            Alamofire.request(url!).response { response in // method defaults to `.get`
                if let data = response.data {
                    if let photo = UIImage(data: data) {
                        // Add photo to cache.
                        let photoToCache = photo
                        self.photoCache.setObject(photoToCache, forKey: post.photoUrl as AnyObject)
                        post.myImage = photoToCache
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
    
    func handleLikes(onCompletion: @escaping () -> Void) {
        let specificPostRef = postRef.child(posts[selectedItemIndex].postKey)
        specificPostRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : Any], let uid = Auth.auth().currentUser?.uid {
                self.posts[self.selectedItemIndex].likes = post["likes"] as! [String : Bool]
                self.posts[self.selectedItemIndex].likeCount = post["likeCount"] as! Int
                if self.posts[self.selectedItemIndex].likes[uid] == true {
                    // Unlike the post and remove self from likes
                    self.posts[self.selectedItemIndex].likeCount -= 1
                    self.posts[self.selectedItemIndex].likes.updateValue(false, forKey: uid)
                    self.posts[self.selectedItemIndex].likelabel = false
                } else {
                    // Like the post and add self to likes
                    self.posts[self.selectedItemIndex].likeCount += 1
                    self.posts[self.selectedItemIndex].likes[uid] = true
                    self.posts[self.selectedItemIndex].likelabel = true
                }
                post["likes"] = self.posts[self.selectedItemIndex].likes as AnyObject?
                post["likeCount"] = self.posts[self.selectedItemIndex].likeCount as AnyObject?
                // Set value and report transaction success
                currentData.value = post
                DispatchQueue.main.async {
                    onCompletion()
                }
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
            
            let newPostID = self.postRef.childByAutoId().key
            let newPostRef = self.postRef.child(newPostID)
            newPostRef.setValue(["post_key": newPostID, "photoUrl": photoUrl, "caption": caption, "user": username, "likes": [uID: false], "likeCount": 0]) { (error, ref) in
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
