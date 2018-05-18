//
//  LoginViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 10..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut() // 시작시 자동으로 로그아웃
        
         // statusbar 설정
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        registerButton.backgroundColor = UIColor(hex: color)

    }
    
    // 로그인버튼 구현
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: loginEmailTextField.text!, password: loginPasswordTextField.text!) { (user, error) in
            // 로그인 실패시
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            // 로그인 성공시
            } else {
                print("login")
            }
        }
    }
}
