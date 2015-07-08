//
//  ParkOKViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/9/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class ParkOKViewController: UIViewController {

    @IBOutlet weak var locName: UILabel!
    
    @IBOutlet weak var parkTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        
        navigationItem.titleView = imageView
        self.navigationItem.setHidesBackButton(true, animated: true)

        // Do any additional setup after loading the view.
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var storeLocName : String?
        storeLocName = prefs.objectForKey("loc") as? String
        if(storeLocName != nil){
            g_Park = storeLocName!
            self.locName.text = stringHelper.getLoc(storeLocName!)
        }
        var parkT : String?
        parkT = prefs.objectForKey("parkTime") as? String
        if(parkT == nil || parkT == ""){
            self.parkTime.text = "- : -"
        }
        else {
            self.parkTime.text = parkT
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Close(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
 //       self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
