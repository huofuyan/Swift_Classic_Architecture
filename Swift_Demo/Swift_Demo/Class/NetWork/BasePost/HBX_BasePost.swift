//
//  HBX_BasePost.swift
//  Swift_Demo
//
//  Created by apple on 2017/11/13.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class HBX_BasePost: NSObject {
    
    //获取公钥
    @objc func getRSAKeyCodeSuccessBlock(successBlock:@escaping (_ rsa: Dictionary<String, Any>) -> (),faileBlock:@escaping (_ error: Error)->()) {
        
        let urlstr = "http://10.0.85.56:8081/public/approve"
        
        let url = URL(string: urlstr)
        
        let session = URLSession.shared
        
//        let task = URLSessionDownloadTask.init()
        
        var requestM = URLRequest(url: url!)
        
        requestM.httpMethod = "POST"
        
        requestM.addValue("iOS", forHTTPHeaderField: "User-Agent")
        
        requestM.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let infoDictionary = Bundle.main.infoDictionary
        
        let versionValue = infoDictionary!["CFBundleShortVersionString"]
        
        let bundIDValue = "ios_version"
        
        let param = ["appflag":bundIDValue, "appversion":versionValue,"openid":"openid"]
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: param, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            
            requestM.httpBody = jsonData
        } catch  {
            
            print("jsonData---错误")
        }
        
        //加载cooike
        self.loadCookies()
        
        let cookies = HTTPCookieStorage.shared.cookies(for: url!)
        
        let sheaders = HTTPCookie.requestHeaderFields(with: cookies!)
        
        requestM.allHTTPHeaderFields = sheaders
        
        //发起请求
        session.dataTask(with: requestM) { (data, urlResponse, error) in
            
            self.saveCookies()
            
            if data != nil && error == nil {
                
                do {
                    
                    let result:[String :Any] = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) as! [String : Any]
                    
                    if result["resultcode"] as! Int == 0 {
                        
                        let modulus: String = result["modulus"] as! String
                        
                        let exp: String = result["exp"] as! String
                        
                        if modulus.count > 0 && exp.count > 0 {
                            
                            let userShare = UserDefaults.standard
                            
                            userShare.set(modulus, forKey: "modulus")
                            userShare.set(exp, forKey: "exp")
                            
                            SVRSAHandler.sharedDFRSA().token = result["token"] as! String
                            
                        }
                        
                        successBlock(result)
                    }
                    if result["resultcode"] as! Int == 7 {
                        
                        print("强制更新提示")
                    }
                }catch {
                    
                    print("data---data解析错误")
                }
            }else {
                
                faileBlock(error!)
                print(error as Any)
            }
        }.resume()
    }
    //加载cookie
    func loadCookies()  {
        
        guard let data = UserDefaults.standard.object(forKey: "org.skyfox.cookie") else {return}
        
        let cookies = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
        
        let cookiesArray = cookies as! Array<Any>
        
        let cookiesStore = HTTPCookieStorage.shared
        
        for cookie in cookiesArray {
            
            cookiesStore.setCookie(cookie as! HTTPCookie)
            
        }
    }
    
    //保存cookie
    
    func saveCookies() {
        
        let cookie = HTTPCookieStorage.shared.cookies
        
        let cookiesData = NSKeyedArchiver.archivedData(withRootObject: cookie!)
        
        let defaults = UserDefaults.standard
        
        defaults.set(cookiesData, forKey: "org.skyfox.cookie")
        
    }
}
