//
//  ContactViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/9/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView

        
        navigationItem.titleView = imageView
        let backBtn = UIBarButtonItem(image:UIImage(named:"back-18.png"), style:.Plain, target:self, action:"barButtonItemClicked:")
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.grayColor()
 

      
 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func barButtonItemClicked(sender:UIButton!)
    {
          self.navigationController?.popViewControllerAnimated(true)
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func callClientService(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://+8637169322200")!)
    
    }
    @IBAction func callTechService(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://+8613523563424")!)        
    }
}
