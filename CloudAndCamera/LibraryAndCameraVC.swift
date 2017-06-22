import UIKit
import MobileCoreServices


class LibraryAndCameraVC: UIViewController {

    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    let picker = UIImagePickerController()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            present(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraButtonPushed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            present(picker,animated: true,completion: nil)
        }
        else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }

    @IBAction func libraryButtonPushed(_ sender: UIButton) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func handleSelectedProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

}


// Extension to allow user to choose profile image from photo library.
extension LibraryAndCameraVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
        }
        dismiss(animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        let shareVC = storyboard.instantiateViewController(withIdentifier: "ShareVC") as! ShareVC
        shareVC.shareImage = selectedImage
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(shareVC, animated: true)
    }
}
