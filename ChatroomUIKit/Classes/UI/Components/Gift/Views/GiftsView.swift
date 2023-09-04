//
//  GiftsView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

@objc final public class GiftsView: UIView {

    var gifts = [GiftEntityProtocol]()

    private var sendClosure: ((GiftEntityProtocol) -> Void)?

    lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.frame.width - 30) / 4.0, height: (110 / 84.0) * (self.frame.width - 30) / 4.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.footerReferenceSize = CGSize(width: self.frame.width, height: 180)
        return layout
    }()

    lazy var giftList: UICollectionView = {
        UICollectionView(frame: CGRect(x: 15, y: 10, width: ScreenWidth - 30, height: self.frame.height), collectionViewLayout: self.flowLayout).registerCell(GiftEntityCell.self, forCellReuseIdentifier: "GiftEntityCell").delegate(self).dataSource(self).showsHorizontalScrollIndicator(false).backgroundColor(.clear).showsVerticalScrollIndicator(false).backgroundColor(.clear).registerView(UICollectionReusableView.self, UICollectionView.elementKindSectionFooter , "AGiftsFooter")
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    
    @objc public convenience init(frame: CGRect, gifts: [GiftEntityProtocol], sentGift: @escaping ((GiftEntityProtocol) -> Void)) {
        self.init(frame: frame)
        self.sendClosure = sentGift
        self.gifts = gifts
        self.giftList.bounces = false
        self.addSubViews([self.giftList])
        
        self.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
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
            guard let entity = $0 else { return }
            if self?.sendClosure != nil {
                self?.sendClosure!(entity)
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
            self.sendClosure?(gift)
        }
        self.giftList.reloadData()
    }

}


