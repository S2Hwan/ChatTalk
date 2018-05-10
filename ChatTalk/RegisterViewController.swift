//
//  RegisterViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 10..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // statusbar 설정
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker))) // 프로필 사진 누르면 사진첩으로 이동
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        joinButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
//        joinButton.addTarget(self, action: #selector(register), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
}
    
    // 사진첩에서 이미지 불러오기
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true // 편집가능
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
    }
    
    
    // join 버튼 - 사용자 인증하기
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in

//            if error != nil {
//                print(error!)
//            } else {
//                print("Log in successful")
//            }
            
            // 데이터베이스에 사용자 정보 저장 및 스토리지에 사진 저장
            let userID = Auth.auth().currentUser!.uid
            let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1)
            
            //StorageReference.downloadURL(StorageReference.child(userID))
            
            Storage.storage().reference().child("userProfileImages").child(userID).putData(image!) // 스토리지에 프로필 사진 저장
            
            Database.database().reference().child("users").child(userID).setValue(["name":self.nameTextField.text!]) // 사용자 정보 저장
            
            //Database.database().reference().child("users").child(userID).setValue(["name":self.nameTextField.text!, "profileImage":self.imageView])
    }

    }
    
    // cancel 버튼
    @IBAction func cancelButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)
    }

    
    
//    @objc func register() {
//
//        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
//            let uid = user?.user
//
//            Database.database().reference().child("users").setValue(["name":self.nameTextField.text])
//
//        }
//
//
//
//    }
//
//    @objc func cancel() {
//
//        self.dismiss(animated: true, completion: nil)
//
//    }
//
//
    
}
