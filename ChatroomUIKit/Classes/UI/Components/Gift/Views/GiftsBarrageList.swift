//
//  GiftsBarrageList.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit


@objc public protocol IGiftsBarrageListDriver {
    /// Description Refresh the UI after receiving the gift
    /// - Parameter gift: GiftEntityProtocol
    func receiveGift(gift: GiftEntityProtocol)
}

@objc public protocol GiftsBarrageListDataSource: NSObjectProtocol {
    @objc optional func rowHeight() -> CGFloat
    @objc optional func zoomScaleX() -> CGFloat
    @objc optional func zoomScaleY() -> CGFloat
}

@objc open class GiftsBarrageList: UIView {
    
    public var dataSource: GiftsBarrageListDataSource?
    
    public var gifts = [GiftEntityProtocol]() {
        didSet {
            if self.gifts.count > 0 {
                self.isHidden = false
                self.cellAnimation()
            }
        }
    }

    private var lastOffsetY = CGFloat(0)

    public lazy var giftList: UITableView = {
        UITableView(frame: CGRect(x: 5, y: 0, width: self.frame.width - 20, height: self.frame.height), style: .plain).tableFooterView(UIView()).separatorStyle(.none).showsVerticalScrollIndicator(false).showsHorizontalScrollIndicator(false).delegate(self).dataSource(self).backgroundColor(.clear).isUserInteractionEnabled(false)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Description Init method.
    /// - Parameters:
    ///   - frame: Layout coordinates
    ///   - source: GiftsBarrageListDataSource
    @objc public convenience init(frame: CGRect, source: GiftsBarrageListDataSource? = nil) {
        self.init(frame: frame)
        self.dataSource = source
        self.backgroundColor = .clear
        self.addSubview(self.giftList)
        self.giftList.isScrollEnabled = false
        self.giftList.isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


extension GiftsBarrageList: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.gifts.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.dataSource?.rowHeight?() ?? 64
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        cell.alpha = 0
        cell.isUserInteractionEnabled = false
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "GiftBarrageCell") as? GiftBarrageCell
        if cell == nil {
            cell = GiftBarrageCell(style: .default, reuseIdentifier: "GiftBarrageCell")
        }
        if let entity = self.gifts[safe: indexPath.row] {
            cell?.refresh(item: entity)
        }
        return cell ?? GiftBarrageCell()
    }

    internal func cellAnimation() {
        self.alpha = 1
        self.giftList.reloadData()
        var indexPath = IndexPath(row: 0, section: 0)
        if self.gifts.count >= 2 {
            indexPath = IndexPath(row: self.gifts.count - 2, section: 0)
        }
        if self.gifts.count > 1{
            let cell = self.giftList.cellForRow(at: indexPath) as? GiftBarrageCell
            guard let gift = self.gifts[safe: indexPath.row] else { return }
            cell?.refresh(item: gift)
            UIView.animate(withDuration: 0.3) {
                cell?.alpha = 0.35
                cell?.contentView.transform = CGAffineTransform(scaleX: self.dataSource?.zoomScaleX?() ?? 0.75, y: self.dataSource?.zoomScaleY?() ?? 0.75)
                self.giftList.scrollToRow(at: IndexPath(row: self.gifts.count - 1, section: 0), at: .top, animated: false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, delay: 1, options: .curveEaseInOut) {
                self.alpha = 0
                self.isHidden = true
            } completion: { _ in
                self.gifts.removeAll()
            }
        }
    }
}

extension GiftsBarrageList: GiftsBarrageListDataSource {
    public func rowHeight() -> CGFloat {
        64
    }
    
    public func zoomScaleX() -> CGFloat {
        0.75
    }
    
    public func zoomScaleY() -> CGFloat {
        0.75
    }
}

extension GiftsBarrageList: IGiftsBarrageListDriver {
    public func receiveGift(gift: GiftEntityProtocol) {
        self.gifts.append(gift)
    }
}
