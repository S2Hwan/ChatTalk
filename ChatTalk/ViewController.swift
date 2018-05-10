//
//  ViewController.swift
//  ChatTalk
//
//  Created by S2H on 2018. 5. 10..
//  Copyright © 2018년 S2H. All rights reserved.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig : RemoteConfig!

    override func viewDidLoad() {
        super.viewDidLoad()

        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        
        // 서버와 연결 안될시
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // 서버값 받는 부분
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }

        
        
        // 화면 실행시 첫 로딩 화면
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        box.image = #imageLiteral(resourceName: "starticon")
        // self.view.backgroundColor = UIColor(hex: "#000000")
        
        
    }

    func displayWelcome() {
        
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if(caps) {
            
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: false, completion: nil)
            
        }
        self.view.backgroundColor = UIColor(hex: color!)
        
    }
 


}

// https://crunchybagel.com/working-with-hex-colors-in-swift-3/
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1 // #aabbcc -> #이 아닌 a부터 읽기위해 1로 지정
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
