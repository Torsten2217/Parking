//
//  AccountTableViewCell.swift
//  Park-iOS
//
//  Created by Dieter Kohl on 5/27/15.
//  Copyright (c) 2015 Dieter Kohl. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell , UITextFieldDelegate {

    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPhone: UITextField!
    
    //@IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUser: UITextField!
    
    @IBOutlet weak var txtPass: UITextField!
    
    
    @IBOutlet weak var txtConfirm: UITextField!
    
    @IBOutlet weak var weChat: UISwitch!
    
    @IBOutlet weak var qqSwitch: UISwitch!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.txtName.delegate = self;
        self.txtEmail.delegate = self;
 
        
        self.txtPhone.delegate = self;
        self.txtUser.delegate = self;
        
        self.txtPass.delegate = self;
        self.txtConfirm.delegate = self;
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

