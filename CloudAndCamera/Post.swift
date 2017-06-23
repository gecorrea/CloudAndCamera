import Foundation

class Post{
    var postKey: String
    var user: String
    var caption: String
    var photoUrl: String
    var likes = Dictionary <String, Bool>()
    var likeCount = Int()
    var myImage: UIImage?
    var likelabel = false
    
    
    init(postKeyString: String, userString: String, captionString: String, photoUrlString: String, likeNumber: Int) {
        postKey = postKeyString
        user = userString
        caption = captionString
        photoUrl = photoUrlString
        likeCount = likeNumber
    }
}
