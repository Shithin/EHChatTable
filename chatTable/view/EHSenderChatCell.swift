//
//  EHSenderChatCell.swift
//  chatTable
//
//  Created by Shithin PV on 01/01/18.
//  Copyright © 2018 e3Help. All rights reserved.
//

import UIKit

class EHSenderChatCell: UITableViewCell {

    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraintOfChatLabel: NSLayoutConstraint!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profilePic.layer.cornerRadius = 15
        self.chatView.layer.cornerRadius = 10
        self.chatView.layer.masksToBounds = true
    }

}
