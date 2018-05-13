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
    
    var imageRef : StorageReference {
        return Storage.storage().reference().child("profileImage")
    }
    
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
        
        
//        imageView.isUserInteractionEnabled = true
//        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker))) // 프로필 사진 누르면 사진첩으로 이동
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        joinButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)
        
//        joinButton.addTarget(self, action: #selector(register), for: .touchUpInside)
//        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = image
        
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    // 사진첩에서 이미지 불러오기
//    @objc func imagePicker() {
//        let imagePicker = UIImagePickerController()
//
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true // 편집가능
//        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        self.present(imagePicker, animated: true, completion: nil)
//
//    }
    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//
//        dismiss(animated: true, completion: nil)
//    }
    
    
    // join 버튼 - 사용자 인증하기
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            // 데이터베이스에 사용자 정보 저장 및 스토리지에 사진 저장
            let userID = Auth.auth().currentUser!.uid
        
            //let image = UIImageJPEGRepresentation(self.imageView.image!, 0.1)
            
            // 스토리지에 저장
            guard let image = self.imageView.image else { return }
            guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return }
            
            let uploadImageRef = self.imageRef.child(userID)
            
            let uploadTask = uploadImageRef.putData(imageData, metadata: nil) { (metadata, error) in
                print("uploadTask")
                print(metadata ?? "no metadata")
                print(error ?? "no error")
                
               // let imageUrl = StorageReference.downloadURL(self.imageRef)
               
                
               // StorageReference.downloadURL("gs://talk-63677.appspot.com")
                
            }
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "no more progress")
            }
            uploadTask.resume()
            
 
            //StorageReference.downloadURL(StorageReference.child(userID))
            
            //Storage.storage().reference().child("userProfileImages").child(userID).putData(image) // 스토리지에 프로필 사진 저장
            
            //Database.database().reference().child("users").child(userID).setValue(["name":self.nameTextField.text!, "images":UIImagePickerControllerImageURL]) // 사용자 정보 저장
            
            let userDB = Database.database().reference().child("usersData")
            let userDictionary = ["name":self.nameTextField.text!, "userimage":userID] as [String : Any]//
            
            userDB.childByAutoId().setValue(userDictionary, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!)
                } else {
                    print("good")
                }
            })
            
//            userDB.childByAutoId().setValue(userDictionary, withCompletionBlock: { (error, ref) in
//                if error != nil {
//                    print(error!)
//                } else {
//                    print("good")
//                }
//            })
            
//            userDB.childByAutoId().setValue(userDictionary) {
//                (error, reference) in
//                if error != nil {
//                    print(error!)
//                } else {
//                    print("Message saved successfully!")
//            }
//            }
            
            
            //
//            let storage = Storage.storage()
//            var data = Data()
//            data = UIImagePNGRepresentation("lock")! // image file name
//            // Create a storage reference from our storage service
//            let storageRef = storage.reference()
//            var imageRef = storageRef.child("images/lock.png")
//            _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
//                guard let metadata = metadata else{
//                    print(error)
//                    return
//                }
//                let downloadURL = metadata.downloadURL()
//                print(downloadURL)
//            })
                // Create a reference to the file you want to download
       
                
            
         
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
