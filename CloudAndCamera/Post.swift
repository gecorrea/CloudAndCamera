import Foundation

class Post{
    var postKey: String
    var users = Array<String>()
    var comments = Array<String>()
    var commentCount = Int()
    var likes = Dictionary <String, Bool>()
    var likeCount = Int()
    var photoUrl: String
    var myImage: UIImage?
    var likelabel = false
    
    
    init(postKey: String, usersArray: [String], commentsArray: [String], commentCount: Int, likeCount: Int, photoUrl: String) {
        self.postKey = postKey
        users.append(contentsOf: usersArray)
        comments.append(contentsOf: commentsArray)
        self.commentCount = commentCount
        self.likeCount = likeCount
        self.photoUrl = photoUrl
    }
}
