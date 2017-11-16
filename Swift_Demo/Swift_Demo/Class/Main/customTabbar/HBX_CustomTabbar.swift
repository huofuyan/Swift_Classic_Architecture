//
//  HBX_CustomTabbar.swift
//  Swift_Demo
//
//  Created by apple on 2017/11/9.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit




class HBX_CustomTabbar: UITabBar {
    
    @objc func clickCenterButton()  {
        
    }
    
    lazy var centerButton: UIButton = {
        
        let pointx = self.bounds.origin.x
        let pointy = self.bounds.origin.y
        
        let button = UIButton(frame: CGRect(x: pointx, y: pointy, width: 40, height: 40))
        
        button.setImage(UIImage(named: "ime_home"), for: UIControlState.normal)
        
        button.addTarget(self, action: #selector(clickCenterButton), for: .touchUpInside)
        
        return button
    }()
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var tabbarButtonArrayM = [NSObject]()
        
        for view in self.subviews {
            
            if view.isKind(of: NSClassFromString("UITabBarButton")!){
                
                tabbarButtonArrayM.append(view)
                
            }
        }
        
        let barWidth = bounds.size.width
        
        let barHeight = bounds.size.height
        
        //中间按钮宽度
//        let centerButtonWidth = centerButton.frame.width
        
        //中间按钮高度
//        let centerButtonHeight = centerButton.frame.height
        
        //中间按钮的位置
        centerButton.center = CGPoint(x: barWidth / 2, y: 27)
        
        //item 宽度
        let barItemWidth = (barWidth) / (CGFloat(tabbarButtonArrayM.count) + 1)
        
        
        for item in tabbarButtonArrayM.enumerated() {
            
            let view: UIView = item.element as! UIView
            
            let index = item.offset
            
            var frame = view.frame
            
            if index >= tabbarButtonArrayM.count / 2 {
                
                frame.origin.x = barItemWidth * CGFloat(index + 1)
            }else {
                frame.origin.x = barItemWidth * CGFloat(index)
            }
            
            frame.size.width = barItemWidth
            
            view.frame = frame
            
            self.addSubview(centerButton)
            
            self.bringSubview(toFront: centerButton)

        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if self.clipsToBounds || self.isHidden || self.alpha == 0 {
            return nil
        }
        
        var resultView = super.hitTest(point, with: event)
        
        if (resultView != nil) {
            return resultView
        }
        
        for subView in self.subviews {
            
            // 把这个坐标从tabbar的坐标系转为 subview 的坐标系
            
            let subPoint = subView.convert(point, from: self)
        
            resultView = subView.hitTest(subPoint, with: event)
            
            if (resultView != nil) {
                
                return resultView
            }
            
        }
        
        return nil
    }
}
