//
//  RegisterViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 10..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color : String!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        // statusbar 설정
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        joinButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
        
    }
    
    // 이미지 선택 버튼
    @IBAction func changeImageButton(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
        imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // join 버튼 - 사용자 인증하기
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, err) in
            let uid = user?.uid
            
            let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1)
            
            
            Storage.storage().reference().child("userImages").child(uid!).putData(image!, metadata: nil, completion: { (data, error) in
                
                let imageUrl = data?.downloadURL()?.absoluteString
                let values = ["userName":self.nameTextField.text!,"profileImageUrl":imageUrl,"uid":Auth.auth().currentUser?.uid]
                
                Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                    
                    if(err==nil){
                        self.cancel()
                    }
                })
            })
        }
    }
    
    func cancel() {
         self.dismiss(animated: true, completion: nil)
    }

    // cancel 버튼
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        
        cancel()
    }
}

