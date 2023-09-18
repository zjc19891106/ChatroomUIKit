//
//  GiftsView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

/// GiftsView event actions delegate
@objc public protocol GiftsViewActionEventsDelegate: NSObjectProtocol {
    
    /// Send button click
    /// - Parameter item: `GiftEntityProtocol`
    func onGiftSendClick(item: GiftEntityProtocol)
    
    /// Select a gift item.
    /// - Parameter item: `GiftEntityProtocol`
    func onGiftSelected(item: GiftEntityProtocol)
}

@objcMembers open class GiftsView: UIView {
        
    private var eventHandlers: NSHashTable<GiftsViewActionEventsDelegate> = NSHashTable<GiftsViewActionEventsDelegate>.weakObjects()
    
    /// Add UI action handler.
    /// - Parameter actionHandler: ``GiftsViewActionEventsDelegate``
    public func addActionHandler(actionHandler: GiftsViewActionEventsDelegate) {
        if self.eventHandlers.contains(actionHandler) {
            return
        }
        self.eventHandlers.add(actionHandler)
    }

    /// Remove UI action handler.
    /// - Parameter actionHandler: ``GiftsViewActionEventsDelegate``
    public func removeEventHandler(actionHandler: GiftsViewActionEventsDelegate) {
        self.eventHandlers.remove(actionHandler)
    }

    var gifts = [GiftEntityProtocol]()

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.frame.width - 30) / 4.0, height: (110 / 84.0) * (self.frame.width - 30) / 4.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = CGSize(width: self.frame.width, height: 180)
        return layout
    }()

    lazy var giftList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 15, y: 10, width: self.frame.width - 30, height: self.frame.height), collectionViewLayout: self.flowLayout).registerCell(ComponentsRegister.shared.GiftsCell, forCellReuseIdentifier: "GiftEntityCell").delegate(self).dataSource(self).showsHorizontalScrollIndicator(false).backgroundColor(.clear).showsVerticalScrollIndicator(false).backgroundColor(.clear).registerView(UICollectionReusableView.self, UICollectionView.elementKindSectionFooter , "GiftsFooter")
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(frame: CGRect, gifts: [GiftEntityProtocol]) {
        self.init(frame: frame)
        self.gifts = gifts
        self.giftList.bounces = false
        self.addSubViews([self.giftList])
        self.backgroundColor = .clear
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

extension GiftsView: UICollectionViewDelegate,UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.gifts.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftEntityCell", for: indexPath) as? GiftEntityCell
        cell?.refresh(item: self.gifts[safe: indexPath.row])
        cell?.sendCallback = { [weak self] in
            guard let `self` = self else { return }
            if let gift = $0 {
                for handler in self.eventHandlers.allObjects {
                    handler.onGiftSendClick(item: gift)
                }
            }
        }
        return cell ?? GiftEntityCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GiftsFooter", for: indexPath)
            reusableView.backgroundColor = .clear
            reusableView.frame = CGRect(origin: reusableView.frame.origin, size: CGSize(width: self.frame.width, height: 180))
            return reusableView
        }
        return UICollectionReusableView()
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.gifts.forEach { $0.selected = false }
        if let gift = self.gifts[safe: indexPath.row] {
            gift.selected = true
            for handler in self.eventHandlers.allObjects {
                handler.onGiftSelected(item: gift)
            }
        }
        self.giftList.reloadData()
    }

}


extension UICollectionView {
    /// Dequeues a UICollectionView Cell with a generic type and indexPath
    /// - Parameters:
    ///   - type: A generic cell type
    ///   - indexPath: The indexPath of the row in the UICollectionView
    /// - Returns: A Cell from the type passed through
    func dequeueReusableCell<Cell: UICollectionViewCell>(with type: Cell.Type, for indexPath: IndexPath, reuseIdentifier: String) -> Cell {
        dequeueReusableCell(withReuseIdentifier: reuseIdentifier , for: indexPath) as! Cell
    }
}
