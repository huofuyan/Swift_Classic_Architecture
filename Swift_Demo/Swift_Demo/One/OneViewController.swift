//
//  OneViewController.swift
//  Swift_Demo
//
//  Created by apple on 2017/10/30.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit

class OneViewController: UIViewController,URLSessionDownloadDelegate {
    
    var myProgress: UIProgressView? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(red: (CGFloat(arc4random_uniform(256)) / 255.0), green: (CGFloat(arc4random_uniform(256)) / 255.0), blue: (CGFloat(arc4random_uniform(256)) / 255.0), alpha: 1)
        
        self.creatSession()
        
        
        let button = UIButton(frame: CGRect(x: 100, y: 150, width: 100, height: 60))
        
        button.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        
        button.addTarget(self, action:#selector(startDownload), for: .touchUpInside)
        
        button.setTitle("开始", for: UIControlState.normal)
        
        
        self.view.addSubview(button)
        
        let button1 = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 60))
        
        button1.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        
        button1.addTarget(self, action:#selector(pauseDownload), for: .touchUpInside)
        
        button1.setTitle("暂停", for: UIControlState.normal)

        self.view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRect(x: 250, y: 300, width: 100, height: 60))
        
        button2.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        
        button2.addTarget(self, action:#selector(resumeDownload), for: .touchUpInside)
        
        button2.setTitle("续传", for: UIControlState.normal)
        
        self.view.addSubview(button2)
        
        myProgress = UIProgressView(frame: CGRect(x: 100, y: 420, width: 200, height: 30))
        
        myProgress?.progressViewStyle = .default
        
        myProgress?.progress = 0.5
        
        self.view.addSubview(myProgress!)
        
        
        
    }
    
    //网络回话
    var mysession: URLSession? = nil
    
    //下载地址
    var downUrl: URL? = nil
    
    var downLoadTask: URLSessionDownloadTask? = nil
    
    var resumeData: Data? = nil
    
    func creatSession()  {
        
        //建立回话
        let config = URLSessionConfiguration.default
        
        self.mysession = URLSession.init(configuration: config, delegate: self, delegateQueue: nil)
        
    }
    //开始下载
    @objc func startDownload(){
       
        var url = "http://mting.info:81/asdb/renwensheke/nrcgksm-zs/ntumovdn.mp3"
        
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        self.downUrl = URL(string: url)
        
        downLoadTask = mysession?.downloadTask(with: self.downUrl!)
        
        downLoadTask!.resume()
        
    }
    
    //暂停下载
    @objc func pauseDownload() {
        self.downLoadTask!.cancel(byProducingResumeData: { (resumeData) in
            
//            print(".....",resumeData!)
            
            //将续传数据保存到磁盘
            
            var path: String = (self.downLoadTask?.currentRequest?.url?.lastPathComponent)!
            
          path =  self.appendTempDir(urlstr: path)
            
            let url = URL(string: path)
            
            
        
            do {
                
                try resumeData?.write(to: url!)
                
                //删除任务
                self.downLoadTask = nil
                
                self.resumeData = resumeData
                
            }catch {
                
                print(resumeData! as Any)
                print("出错误了")
            }
        })
    }
    
    //继续下载
    
    @objc func resumeDownload() {
        
        //从沙盒读取续传数据
        if self.resumeData == nil {
            
            return
        }
        
        //任务都是由session发起的
        self.downLoadTask = mysession?.downloadTask(withResumeData: resumeData!)
        
        self.downLoadTask?.resume()
        
        self.resumeData = nil
        
    }
    
    //给当前文件追加临时目录
    func appendTempDir(urlstr: String) -> String {
        
        let dir = NSTemporaryDirectory() as NSString
        
        return dir.appendingPathComponent(urlstr)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   //代理方法
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            
            self.myProgress?.progress = progress
        }
    }

}
