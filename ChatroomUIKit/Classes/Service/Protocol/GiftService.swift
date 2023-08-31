//
//  GiftService.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/8/28.
//

import Foundation
import HyphenateChat

@objc public protocol GiftEntityProtocol: NSObjectProtocol {
    var giftId: String {set get}
    var giftName: String {set get}
    var giftPrice: String {set get}
    var giftCount: String {set get}
    var giftIcon: String {set get}
    /// Description 开发者可以上传服务器一个匹配礼物id的特效  特效名称为礼物的id  sdk会进入房间时拉取礼物资源并下载对应礼物id的特效，如果收到的礼物这个值为true 则会找到对应的特效全屏播放加广播，礼物资源以及特效资源下载服务端可做一个web页面供用户使用，每个app启动后加载场景之前预先去下载礼物资源缓存到磁盘供UIKit取用
    var giftEffect: String {set get}
    
    var selected: Bool {set get}
    
    var sendUser: UserInfoProtocol? {set get}
}

@objc public protocol GiftService: NSObjectProtocol {
    
    /// Description Bind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func bindGiftResponseListener(listener: GiftResponseListener)
    
    /// Description Unbind user state changed listener
    /// - Parameter listener: UserStateChangedListener
    func unbindGiftResponseListener(listener: GiftResponseListener)
    
    /// Description You should fetch gifts data from server.Then init the service Implement.
    /// - Parameters:
    ///   - gifts: gifts map
    ///   - roomId: chatroom id
    init(gifts: [[Dictionary<String,Any>]],roomId: String)
 
    /// Description Send gift.
    /// - Parameters:
    ///   - gift: GiftEntityProtocol
    ///   - completion: Callback,what if success or error.
    func sendGift(gift: GiftEntityProtocol,completion: @escaping (ChatError?) -> Void)
}

@objc public protocol GiftResponseListener: NSObjectProtocol {
    
    /// Description Some one send gift to chatroom
    /// - Parameter gift: GiftEntityProtocol
    func receiveGift(gift: GiftEntityProtocol)
}
