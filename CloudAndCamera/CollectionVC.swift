import UIKit
import FirebaseAuth

class CollectionVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet var collectionView: UICollectionView!
    let reuseIdentifier = "collectionCell"
    let dataManager = DAO.sharedInstance
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    let itemsPerRow: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dataManager.comments.removeAll()
        dataManager.retrieveComments { 
            self.dataManager.loadImagePosts(onSuccess: {
                self.collectionView.reloadData()
            })
        }
    }
    
    
// MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        if let currentCell = collectionView.cellForItem(at: indexPath) as? CustomCell {
            detailVC.detailImage = currentCell.cellImageView.image
            dataManager.selectedItemIndex = indexPath.item
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
        dataManager.comments.removeAll()
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInVC")
        
        self.present(signInVC, animated: true, completion: nil)
    }
}


// UICollectionViewDataSource
extension CollectionVC {
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataManager.comments.count
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
        
        cell.cellImageView.image = dataManager.comments[indexPath.item].myImage
        cell.cellImageView.contentMode = .scaleAspectFill
        
        return cell
    }
}
