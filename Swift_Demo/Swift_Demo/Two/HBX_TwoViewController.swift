//
//  HBX_TwoViewController.swift
//  Swift_Demo
//
//  Created by apple on 2017/11/8.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class HBX_TwoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: (CGFloat(arc4random_uniform(256)) / 255.0), green: (CGFloat(arc4random_uniform(256)) / 255.0), blue: (CGFloat(arc4random_uniform(256)) / 255.0), alpha: 1)
        
        
        let button = UIButton(frame: CGRect(x: 100, y: 150, width: 100, height: 60))
        
        button.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        
        button.addTarget(self, action:#selector(clickButton), for: .touchUpInside)
        
        button.setTitle("开始", for: UIControlState.normal)
        
        
        self.view.addSubview(button)
        
        
        
    }
    
    @objc func clickButton()  {
        
        let basepost = HBX_BasePost()
        
        basepost.getRSAKeyCodeSuccessBlock(successBlock: { (resultDict) in
            
        }) { (error) in
            
        }
        
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
