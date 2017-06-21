import Foundation

class Comment{
    var user: String
    var caption: String
    var photoUrl: String

    
    init(userString: String, captionString: String, photoUrlString: String) {
        user = userString
        caption = captionString
        photoUrl = photoUrlString
    }
}
