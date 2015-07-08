//
//  QRCodeTableViewController.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/16/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit


class QRCodeTableViewController: UITableViewController {

    var urlArray = ["http://zgpulai.com/park_arm.apk", "http://zgpulai.com/park_x86.apk", "http://zgpulai.com/park_arm.apk"]
    var iconArray = ["android.png", "android.png", "ios.png"]
    var labelArray = ["下载(ARM)", "下载(X86)", "下载"]
    
  
    @IBOutlet var qrOnlineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // set top title and back image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 20))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "shareQR")
        imageView.image = image
        
        navigationItem.titleView = imageView
        let backBtn = UIBarButtonItem(image:UIImage(named:"back-18.png"), style:.Plain, target:self, action:"barButtonItemClicked:")
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.grayColor()
        self.qrOnlineTableView.separatorStyle = UITableViewCellSeparatorStyle.None
       
        
        
//                var myImage = UIImage(named: "back-arrow.png")
//        
//                let myInsets : UIEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10)
//                myImage = myImage!.resizableImageWithCapInsets(myInsets)
//        
//                UIBarButtonItem.appearance().setBackButtonBackgroundImage(myImage, forState: .Normal , barMetrics: .Default)
        
//        let backButton = UIBarButtonItem(title: "<-", style: UIBarButtonItemStyle.Plain, target: self, action: "barButtonItemClicked:")
//        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.grayColor()]
//        backButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Helvetica", size: 25)!, NSForegroundColorAttributeName : UIColor.grayColor()], forState: UIControlState.Normal)
//        navigationItem.leftBarButtonItem = backButton
        
 
        

    }
    func barButtonItemClicked(sender:UIButton!)
    {
          self.navigationController?.popViewControllerAnimated(true)        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return urlArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QrCell", forIndexPath: indexPath) as! UITableViewCell

        (cell.contentView.viewWithTag(10) as! UIImageView).image = UIImage(named: iconArray[indexPath.row])
        (cell.contentView.viewWithTag(15) as! UILabel).text = labelArray[indexPath.row] as String

        var qrCode = QRCode(urlArray[indexPath.row])!
        qrCode.size = cell.contentView.viewWithTag(20)!.bounds.size
        (cell.contentView.viewWithTag(20) as! UIImageView).image = qrCode.image

        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
