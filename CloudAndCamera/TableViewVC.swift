import UIKit

class TableViewVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let dataManager = DAO.sharedInstance
    var cell: CustomDetailTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        dataManager.loadProfileImages {
            self.dataManager.loadPhotosFromCache {
                self.tableView.reloadData()
            }
        }
        tableView.allowsSelection = false
    }
}

extension TableViewVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.posts[dataManager.selectedItemIndex].commentCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "customDetailCell", for: indexPath) as! CustomDetailTableViewCell
        if dataManager.posts[dataManager.selectedItemIndex].profileImages.count == dataManager.posts[dataManager.selectedItemIndex].commentCount {
            cell.profileImage.image = dataManager.posts[dataManager.selectedItemIndex].profileImages[indexPath.row]
            cell.username.text = dataManager.posts[dataManager.selectedItemIndex].users[indexPath.row]
            cell.userComment.text = dataManager.posts[dataManager.selectedItemIndex].comments[indexPath.row]
        } else {
            cell.username.text = dataManager.posts[dataManager.selectedItemIndex].users[indexPath.row]
            cell.userComment.text = dataManager.posts[dataManager.selectedItemIndex].comments[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension TableViewVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
