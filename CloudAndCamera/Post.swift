import Foundation

class Post{
    var user: String
    var caption: String
    var photoUrl: String
    var likes = Dictionary <String, Bool>()
    var likeCount = Int()
    var myImage: UIImage?
    var imageName = "icn_like"
    var likelabel = false
    
    
    init(userString: String, captionString: String, photoUrlString: String) {
        user = userString
        caption = captionString
        photoUrl = photoUrlString
    }
}
