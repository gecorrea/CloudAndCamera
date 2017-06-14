import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AuthServices {
    
    
    static func signIn (email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    static func signUp (username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            let uid = user?.uid
            let storageRef = Storage.storage().reference(forURL: Config.STORAGE_ROOT_REF).child("profile_image").child(uid!)
            
            storageRef.putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    return
                }
                if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                    self.setUserInfo(profileImageURL: profileImageURL, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                }
            })
        }
    }
    
    // Save new username, email, and profileImage to firebase storage.
    static func setUserInfo (profileImageURL: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void) {
        let ref = Database.database().reference()
        let userRef = ref.child("users")
        let newUserRef = userRef.child(uid)
        newUserRef.setValue(["username": username, "email": email, "profileImageURL": profileImageURL])
        onSuccess()
    }
}
