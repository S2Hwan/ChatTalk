//
//  ChatViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 19..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var uid : String?
    var chatRoomUid : String?
    
    var comments : [ChatModel.Comment] = []
    var userModel : UserModel?
    
    public var destinationUid :String? // 나중에 내가 채팅할 대상의 uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        
        // 탭바 안보이게 하기
        self.tabBarController?.tabBar.isHidden = true

        // 탭하면 키보드 사라기게 하기
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 키보드 나타내고 없애기
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // 종료시 탭바 보이게하기
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // 키보드 나타내기 설정
    @objc func keyboardWillShow(notification : Notification) {

        if let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.heightConstraint.constant = keyboardSize.height
        }

        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (completion) in
            
            // 스크롤 아래로 내리기
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    // 키보드 숨기기 설정
    @objc func keyboardWillHide(notification : Notification) {
        self.heightConstraint.constant = 20
        self.self.view.layoutIfNeeded()
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 메세지셀에 내용 나타내기
        if(self.comments[indexPath.row].uid == uid) {
            let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            return view
            
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameLabel.text = userModel?.userName
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0
            
            // 프로필 사진 가져오기
            let url = URL(string: (self.userModel?.profileImageUrl)!)
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                DispatchQueue.main.sync {
                    view.imageViewProfile.image = UIImage(data: data!)
                    view.imageViewProfile.layer.cornerRadius = view.imageViewProfile.frame.width/2
                    view.imageViewProfile.clipsToBounds = true
                }
            }.resume()
            return view
            
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
//    public var destinationUid :String? // 나중에 내가 채팅할 대상의 uid
    
    @objc func createRoom(){
        
        let createRoomInfo : Dictionary<String,Any> = [ "users" : [uid!: true, destinationUid! :true]]
        
        if(chatRoomUid == nil){
            self.sendButton.isEnabled = false
            
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                if(err == nil){
                    self.checkChatRoom()
                }
            })
            
        }else{
            let value :Dictionary<String,Any> = ["uid" : uid!, "message" : textFieldMessage.text!]
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { (error, ref) in
                self.textFieldMessage.text = ""
            }
        }
    }
    
    func checkChatRoom(){
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true){
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
                
                
                
            }
        })
        
    }
    
    // 유저 정보 받아오기
    func getDestinationInfo() {
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { (Datasnapshot) in
            self.userModel = UserModel()
            self.userModel?.setValuesForKeys(Datasnapshot.value as! [String:Any])
            self.getMessageList()
        }
    }
    
    // 메세지 리스트 받아오기
    func getMessageList(){
        
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { (datasnapshot) in
            self.comments.removeAll()
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.tableView.reloadData()
            
            // 스크롤 아래로 내리기
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
            }
        })
    }
}

// 메세지셀 만들기
class MyMessageCell : UITableViewCell {
    
    @IBOutlet weak var labelMessage: UILabel!
    
}

class DestinationMessageCell : UITableViewCell {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
}



 















