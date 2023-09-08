//
//  ChatBarrageList.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/5.
//

import UIKit

var chatViewWidth: CGFloat = 0

@objc public protocol IChatBarrageListDriver: NSObjectProtocol {
    func showNewMessage(entity: ChatEntity)
}

@objc public protocol ChatBarrageActionEventsHandler: NSObjectProtocol {
    
    func onMessageBarrageLongPressed(message: ChatMessage)
    
    func onMessageClicked(message: ChatMessage)
}

@objcMembers open class ChatBarrageList: UIView {
    
    private var eventHandlers: NSHashTable<ChatBarrageActionEventsHandler> = NSHashTable<ChatBarrageActionEventsHandler>.weakObjects()
        
    public func addActionHandler(actionHandler: ChatBarrageActionEventsHandler) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }

    public func removeEventHandler(actionHandler: ChatBarrageActionEventsHandler) {
        self.eventHandlers.remove(actionHandler)
    }

    private var lastOffsetY = CGFloat(0)

    private var cellOffset = CGFloat(0)

    public var messages: [ChatEntity]? = [ChatEntity]()

    public lazy var chatView: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), style: .plain).delegate(self).dataSource(self).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).showsVerticalScrollIndicator(false).isUserInteractionEnabled(false)
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        CAGradientLayer().startPoint(CGPoint(x: 0, y: 0)).endPoint(CGPoint(x: 0, y: 0.1)).colors([UIColor.clear.withAlphaComponent(0).cgColor, UIColor.clear.withAlphaComponent(1).cgColor]).locations([NSNumber(0), NSNumber(1)]).rasterizationScale(UIScreen.main.scale).frame(self.blurView.frame)
    }()

    private lazy var blurView: UIView = {
        UIView(frame: CGRect(x: 0, y: 0, width: chatViewWidth, height: self.frame.height)).backgroundColor(.clear)
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        chatViewWidth = frame.width
        self.addSubViews([self.blurView])
        self.blurView.layer.mask = self.gradientLayer
        self.blurView.addSubview(self.chatView)
        self.chatView.bounces = false
        self.chatView.allowsSelection = false
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGesture(gesture:)))
        longGesture.minimumPressDuration = 2.0
        self.chatView.addGestureRecognizer(longGesture)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    } /// 渐变蒙层

}

extension ChatBarrageList:UITableViewDelegate, UITableViewDataSource {
    
    @objc public func scrollTableViewToBottom() {
        if self.messages?.count ?? 0 > 1 {
            self.chatView.scrollToRow(at: IndexPath(row: self.messages!.count-1, section: 0), at: .bottom, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.messages?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.messages?[safe: indexPath.row]?.height ?? 60
        return height
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatBarrageCell") as? ChatBarrageCell
        if cell == nil {
            cell = ChatBarrageCell(barrageStyle: ComponentsRegister.shared.barrageStyle, reuseIdentifier: "ChatBarrageCell")
        }
        guard let entity = self.messages?[safe: indexPath.row] else { return ChatBarrageCell() }
        cell?.refresh(chat: entity)
        cell?.selectionStyle = .none
        return cell!
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.contentOffset.y - self.lastOffsetY < 0 {
            self.cellOffset -= cell.frame.height
        } else {
            self.cellOffset += cell.frame.height
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        for handler in self.eventHandlers.allObjects {
            if let message = self.messages?[safe: indexPath.row]?.message {
                handler.onMessageClicked(message: message)
            }
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = self.chatView.indexPathForRow(at: scrollView.contentOffset) ?? IndexPath(row: 0, section: 0)
        let cell = self.chatView.cellForRow(at: indexPath)
        let maxAlphaOffset = cell?.frame.height ?? 40
        let offsetY = scrollView.contentOffset.y
        let alpha = (maxAlphaOffset - (offsetY - self.cellOffset)) / maxAlphaOffset
        if offsetY - lastOffsetY > 0 {
            UIView.animate(withDuration: 0.3) {
                cell?.alpha = alpha
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                cell?.alpha = 1
            }
        }
        self.lastOffsetY = offsetY
        if self.lastOffsetY == 0 {
            self.cellOffset = 0
        }
    }
    
    @objc func longGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: self.chatView)
            if let indexPath = self.chatView.indexPathForRow(at: touchPoint),let _ = self.chatView.cellForRow(at: indexPath) as? ChatBarrageCell {
                for handler in self.eventHandlers.allObjects {
                    if let message = self.messages?[safe: indexPath.row]?.message {
                        handler.onMessageBarrageLongPressed(message: message)
                    }
                }
            }
        }
    }

}


extension ChatBarrageList: IChatBarrageListDriver {
    public func showNewMessage(entity: ChatEntity) {
        self.messages?.append(entity)
        self.chatView.reloadData()
        self.scrollTableViewToBottom()
    }
}
