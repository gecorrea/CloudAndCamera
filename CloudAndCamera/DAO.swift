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
    var currentUser: String!
    var currentProfileUrl: String!
    let postRef = Database.database().reference().child("posts")
    var delegate: RefreshViewDelegate?
    let photoCache = NSCache <AnyObject, AnyObject>()
    let profilePhotoCache = NSCache <AnyObject, AnyObject>()
    
    // MARK: Methods for CollectionVC
    func retrieveComments(onCompletion: @escaping () -> Void) {
        postRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Any], let uid = Auth.auth().currentUser?.uid {
                for (_, value) in dict {
                    guard let value = value as? [String: Any] else {return}
                    let postKey = value["post_key"] as! String
                    let profileImageUrls = value["profile_urls"] as! [String]
                    let users = value["users"] as! [String]
                    let comments = value["comments"] as! [String]
                    let commentCount = value["comment_count"] as! Int
                    let photoUrl = value["photo_url"] as! String
                    let likeCount = value["like_count"] as! Int
                    let likeLabelDict = value["likes"] as? [String : Bool]
                    let newPost = Post(postKey: postKey, profileImageUrlsArray: profileImageUrls, usersArray: users, commentsArray: comments, commentCount: commentCount, likeCount: likeCount, photoUrl: photoUrl)
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
                self.posts[self.selectedItemIndex].likeCount = post["like_count"] as! Int
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
                post["like_count"] = self.posts[self.selectedItemIndex].likeCount as AnyObject?
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

    func getCurrentUser(onCompletion: @escaping () -> Void) {
        var username = String()
        var profileImageUrl = String()
        let uID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        ref.child("users").child(uID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            username = value?["username"] as! String
            profileImageUrl = value?["profileImageURL"] as! String
            DispatchQueue.main.async {
                self.currentUser = username
                self.currentProfileUrl = profileImageUrl
                onCompletion()
            }
        })
    }

    func postComment(user: String, userPost: String, onCompletion: @escaping () -> Void) {
        let specificPostRef = self.postRef.child(self.posts[self.selectedItemIndex].postKey)
        specificPostRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : Any] {
                self.posts[self.selectedItemIndex].profileImageUrls = post["profile_urls"] as! [String]
                self.posts[self.selectedItemIndex].users = post["users"] as! [String]
                self.posts[self.selectedItemIndex].comments = post["comments"] as! [String]
                self.posts[self.selectedItemIndex].commentCount = post["comment_count"] as! Int
                self.posts[self.selectedItemIndex].profileImageUrls.append(self.currentProfileUrl)
                self.posts[self.selectedItemIndex].users.append(user)
                self.posts[self.selectedItemIndex].comments.append(userPost)
                self.posts[self.selectedItemIndex].commentCount += 1
                post["profile_urls"] = self.posts[self.selectedItemIndex].profileImageUrls as AnyObject?
                post["users"] = self.posts[self.selectedItemIndex].users as AnyObject?
                post["comments"] = self.posts[self.selectedItemIndex].comments as AnyObject?
                post["comment_count"] = self.posts[self.selectedItemIndex].commentCount as AnyObject?
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
    
    func deletePost(onCompletion: @escaping () -> Void) {
        let specificPostRef = self.postRef.child(self.posts[self.selectedItemIndex].postKey)
        specificPostRef.removeValue()
        posts.remove(at: selectedItemIndex)
        onCompletion()
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
    
    func sendDataToDatabase(photoUrl: String, comment: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        let uID = Auth.auth().currentUser!.uid
        var username = String()
        var profileImageUrl = String()
        let ref = Database.database().reference()
        ref.child("users").child(uID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            username = value?["username"] as! String
            profileImageUrl = value?["profileImageURL"] as! String
            let newPostID = self.postRef.childByAutoId().key
            let newPostRef = self.postRef.child(newPostID)
            newPostRef.setValue(["post_key": newPostID, "profile_urls": [profileImageUrl], "users": [username], "comments": [comment], "comment_count": 1, "photo_url": photoUrl, "like_count": 0, "likes": [uID: false]]) { (error, ref) in
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
    
    // MARK: Methods for TableViewVC
    func loadProfileImages(onCompeltion: @escaping () -> Void) {
        let profileUrls = posts[selectedItemIndex].profileImageUrls
        for profileUrl in profileUrls {
            let url = URL(string: profileUrl)
            Alamofire.request(url!).response { response in // method defaults to `.get`
                if let data = response.data {
                    if let photo = UIImage(data: data) {
                        // Add photo to cache.
                        let photoToCache = photo
                        self.profilePhotoCache.setObject(photoToCache, forKey: profileUrl as AnyObject)
                    }
                }
                onCompeltion()
            }
        }
    }
    
    func loadPhotosFromCache(onCompeltion: @escaping () -> Void) {
        posts[selectedItemIndex].profileImages.removeAll()
        let profileUrls = posts[selectedItemIndex].profileImageUrls
        for profileUrl in profileUrls {
            // Load photo from cache if it is there.
            if let photoFromCache = profilePhotoCache.object(forKey: profileUrl as AnyObject) as? UIImage {
                posts[selectedItemIndex].profileImages.append(photoFromCache)
            }
        }
        onCompeltion()
    }
}
