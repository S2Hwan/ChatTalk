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
    
    var uid : String?
    var chatRoomUid : String?
    var comments : [ChatModel.Comment] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let view = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        view.textLabel?.text = self.comments[indexPath.row].message
        return view
    }
    
    public var destinationUid :String? // 나중에 내가 채팅할 대상의 uid
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
    }
    
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
            
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
        }
    }
    
    func checkChatRoom(){
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (Datasnapshot) in
            for item in Datasnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true){
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getMessageList()
                    }
                }
            }
        }
        
    }

    func getMessageList(){
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value) { (Datasnapshot) in
            self.comments.removeAll()
            for item in Datasnapshot.children.allObjects as! [DataSnapshot]{
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                self.comments.append(comment!)
            }
            self.tableView.reloadData()
        }
    }
}