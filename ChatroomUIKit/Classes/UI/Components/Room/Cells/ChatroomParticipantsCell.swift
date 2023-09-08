//
//  ChatroomParticipantsCell.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/8.
//

import UIKit

open class ChatroomParticipantsCell: UITableViewCell {

    var user: UserInfoProtocol?
    
    lazy var userLevel: ImageView = {
        ImageView(frame: CGRect(x: 12, y: (self.contentView.frame.height-26)/2, width: 26, height: 26)).backgroundColor(.clear).contentMode(.scaleAspectFit)
    }()
    
    lazy var userAvatar: ImageView = {
        ImageView(frame: CGRect(x: self.userLevel.frame.maxX+12, y: (self.contentView.frame.height-40)/2, width: 40, height: 40)).backgroundColor(.clear).contentMode(.scaleAspectFit)
    }()

}
