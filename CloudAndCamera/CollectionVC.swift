import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RefreshViewDelegate {
    
    
    @IBOutlet var collectionView: UICollectionView!
    let reuseIdentifier = "collectionCell"
    let dataManager = DAO.sharedInstance
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    let itemsPerRow: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        dataManager.delegate = self
        dataManager.retrieveComments(onCompletion: dataManager.loadImagePosts)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        if let currentCell = collectionView.cellForItem(at: indexPath) as? CustomCell {
            detailVC.detailImage = currentCell.cellImageView.image
            dataManager.postIDKey = dataManager.postIDKeys[indexPath.row]
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @IBAction func logOut(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC")
        
        self.present(signInVC, animated: true, completion: nil)
    }
    
    func refreshView() {
        self.collectionView.reloadData()
    }
}

// UICollectionViewDataSource
extension CollectionVC {
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.images.count
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CustomCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        cell.cellImageView.image = dataManager.images[indexPath.row]
        cell.cellImageView.contentMode = .scaleAspectFill
        
        return cell
    }
}
