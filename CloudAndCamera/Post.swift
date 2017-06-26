import Foundation

class Post{
    var postKey: String
    var profileImageUrls = Array<String>()
    var profileImages = Array<UIImage?>()
    var users = Array<String>()
    var comments = Array<String>()
    var commentCount = Int()
    var likes = Dictionary <String, Bool>()
    var likeCount = Int()
    var photoUrl: String
    var myImage: UIImage?
    var likelabel = false
    
    
    init(postKey: String, profileImageUrlsArray: [String], usersArray: [String], commentsArray: [String], commentCount: Int, likeCount: Int, photoUrl: String) {
        self.postKey = postKey
        profileImageUrls.append(contentsOf: profileImageUrlsArray)
        users.append(contentsOf: usersArray)
        comments.append(contentsOf: commentsArray)
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.photoUrl = photoUrl
    }
}
