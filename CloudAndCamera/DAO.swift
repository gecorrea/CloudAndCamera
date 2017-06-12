import UIKit
import Firebase

class DAO: NSObject {
    
    let storage = Storage.storage()
    
    // Create a reference to moments
    let ref = Database.database().reference(withPath: "moments")
    
 
}
