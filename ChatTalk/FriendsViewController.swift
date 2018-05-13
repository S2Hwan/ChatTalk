////
////  MainViewController.swift
////  ChatTalk
////
////  Created by S2H on 2018. 5. 11..
////  Copyright © 2018년 S2H. All rights reserved.
////
//
//import UIKit
//import SnapKit
//import Firebase
//
//class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    
//    var array : [UserModel] = []
//    var tableview : UITableView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableview = UITableView()
//        tableview.delegate = self
//        tableview.dataSource = self
//        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        view.addSubview(tableview)
//        tableview.snp.makeConstraints { (make) in
//            make.top.equalTo(view).offset(20)
//            make.bottom.left.right.equalTo(view)
//        }
//        
//        Database.database().reference().child("users").observe(DataEventType.value) { (snapShot) in
//            
//            self.array.removeAll() // 데이터 지우기(중복 방지)
//            for child in snapShot.children{
//                let fchild = child as! DataSnapshot
//                let userModel = UserModel()
//                
//                userModel.setValuesForKeys(fchild.value as! [String : Any])
//                self.array.append(userModel)
//            }
//            
//            // 데이터 갱신
//            DispatchQueue.main.async {
//                self.tableview.reloadData()
//            }
//            
//            
//        }
//        
//        
//        
//        func tableView(_ tableVIew: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
//            return 50
//        }
//    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return array.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        
//        let imageview = UIImageView()
//        cell.addSubview(imageview)
//        imageview.snp.makeConstraints { (make) in
//            make.centerY.equalTo(cell)
//            make.left.equalTo(cell)
//            make.height.width.equalTo(50)
//        }
//        
//        
//        
////        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].userProfileImages!)!) { (data, response, error) in
////
////            DispatchQueue.main.async {
////                imageview.image = UIImage(data: data!)
////                imageview.layer.cornerRadius = imageview.frame.size.width/2
////                imageview.clipsToBounds = true
////            }
////            }.resume()
//        
//        let label = UILabel()
//        cell.addSubview(label)
//        label.snp.makeConstraints { (make) in
//            make.centerY.equalTo(cell)
//            make.left.equalTo(imageview.snp.right).offset(30)
//        }
//        
//        label.text = array[indexPath.row].userName
//        
//        return cell
//        
//        
//    }
//}
