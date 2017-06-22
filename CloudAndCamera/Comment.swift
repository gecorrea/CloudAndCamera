import Foundation

class Comment{
    var user: String
    var caption: String
    var photoUrl: String
    var key: String
    var myImage: UIImage?

    
    init(userString: String, captionString: String, photoUrlString: String, keyString: String) {
        user = userString
        caption = captionString
        photoUrl = photoUrlString
        key = keyString
    }
}
