//
//  HBX_BaseViewController.swift
//  Swift_Demo
//
//  Created by apple on 2017/10/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class HBX_BaseViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addChildViewControllers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addChildViewControllers() {
        
        var arrayM = [UIViewController]()
        
        arrayM.append(self.viewControllerWithClsName(vc: OneViewController(), title: "首页", imageName: "tab_icon_home"))
        
        arrayM.append(self.viewControllerWithClsName(vc: HBX_TwoViewController(), title: "首页", imageName: "tab_icon_home"))
        
        arrayM.append(self.viewControllerWithClsName(vc: HBX_ThreeViewController(), title: "首页", imageName: "tab_icon_home"))
        arrayM.append(self.viewControllerWithClsName(vc: HBX_FourViewController(), title: "首页", imageName: "tab_icon_home"))
        
        
        self.viewControllers = arrayM
    }
    
    func viewControllerWithClsName(vc: UIViewController,title: String, imageName: String) -> UIViewController {
        
        vc.title = title;
        
        let image = UIImage(named: imageName)!
        
        vc.tabBarItem.image = image
        
        let imageSel = "\(imageName)_sel"
        
        vc.tabBarItem.selectedImage = UIImage(named: imageSel)
        
        let nav: UIViewController = HBX_NavViewController(rootViewController: vc)

        return nav
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
