//
//  fTableViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 19..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase

class FriendsTableViewController: UITableViewController {
    
    var array : [UserModel] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
            
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                
                if(userModel.uid == myUid){
                    continue
                }
                
                
                self.array.append(userModel)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        })

        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       

        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for :indexPath)
        
        
        let imageview = UIImageView()
        cell.addSubview(imageview)
        imageview.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { (data, response, err) in
            
            
            DispatchQueue.main.async {
                imageview.image = UIImage(data: data!)
                imageview.layer.cornerRadius = imageview.frame.size.width/2
                imageview.clipsToBounds = true
            }
            
            }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageview.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].userName
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        self.navigationController?.pushViewController(view!, animated: true)
    }
    
  
  

  
}
