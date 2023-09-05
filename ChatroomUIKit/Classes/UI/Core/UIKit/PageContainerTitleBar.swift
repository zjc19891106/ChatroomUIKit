//
//  PageContainer.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit

@objc final class PageContainerTitleBar: UIView {
    
    var datas: [String] = []
    
    var chooseClosure: ((Int)->())?
    
    private var theme: ThemeStyle = .light
    
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: 16, y: 8, width: 114, height: self.frame.height-16)).cornerRadius(14).backgroundColor(UIColor(0xD8D8D8))
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: 114, height: self.frame.height-16)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        return flow
    }()
    
    lazy var choicesBar: UICollectionView = {
        UICollectionView(frame: CGRect(x: 16, y: 8, width: self.frame.width-32, height: self.frame.height-16), collectionViewLayout: self.layout).dataSource(self).delegate(self).registerCell(ChoiceItemCell.self, forCellReuseIdentifier: NSStringFromClass(ChoiceItemCell.self)).showsHorizontalScrollIndicator(false).backgroundColor(.clear)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(frame: CGRect, choices: [String], selectedClosure: @escaping (Int)->()) {
        self.init(frame: frame)
        self.chooseClosure = selectedClosure
        self.datas = choices
        self.addSubViews([self.indicator,self.choicesBar])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PageContainerTitleBar: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ChoiceItemCell.self), for: indexPath) as? ChoiceItemCell else {
            return ChoiceItemCell()
        }
        cell.refresh(text: self.datas[indexPath.row])
        cell.content.textColor(self.theme == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25) {
            self.indicator.frame = CGRect(x: 16+CGFloat(indexPath.row)*114, y: 8, width: 114, height: (self.frame.height-16))
        }
        self.chooseClosure?(indexPath.row)
    }
    
    @objc public func scrollIndicator(to index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.indicator.frame = CGRect(x: 16+CGFloat(index)*114, y: 8, width: 114, height: (self.frame.height-16))
        }
    }


}

extension PageContainerTitleBar: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
        self.indicator.backgroundColor(style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5)
        self.choicesBar.reloadData()
    }
    
    public func switchHues(hues: [CGFloat]) {
        UIColor.ColorTheme.switchHues(hues: hues)
        self.switchTheme(style: .light)
    }
}


@objc final class ChoiceItemCell: UICollectionViewCell {
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).textAlignment(.center).textColor(UIColor.theme.neutralColor1).font(.systemFont(ofSize: 14, weight: .semibold)).backgroundColor(.clear)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
    }
    
    func refresh(text: String) {
        self.content.text = text
    }
}


/// Description Choice layout
@objcMembers public final class ChoiceItemLayout: UICollectionViewFlowLayout {
    
    internal var center: CGPoint!
    internal var rows: Int!
    
    
    private var deleteIndexPaths: [IndexPath]?
    private var insertIndexPaths: [IndexPath]?
    
    public override func prepare() {
        let size = self.collectionView?.frame.size ?? .zero
        self.rows = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        self.center = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //Calculate per item center
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.size = self.itemSize
        if self.rows == 1 {
            attributes.center = self.center
        }
        return attributes
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        for index in 0 ..< self.rows {
            let indexPath = IndexPath(item: index, section: 0)
            attributesArray.append(self.layoutAttributesForItem(at:indexPath)!)
        }
        return attributesArray
    }
    
    
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        self.deleteIndexPaths = [IndexPath]()
        self.insertIndexPaths = [IndexPath]()
        
        for updateItem in updateItems {
            if updateItem.updateAction == UICollectionViewUpdateItem.Action.delete {
                guard let indexPath = updateItem.indexPathBeforeUpdate else { return }
                self.deleteIndexPaths?.append(indexPath)
            } else if updateItem.updateAction == UICollectionViewUpdateItem.Action.insert {
                guard let indexPath = updateItem.indexPathAfterUpdate else { return }
                self.insertIndexPaths?.append(indexPath)
            }
        }
        
    }
    
    public override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        self.deleteIndexPaths = nil
        self.insertIndexPaths = nil
    }
    
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //Appear animation
        var attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if self.insertIndexPaths?.contains(itemIndexPath) ?? false {
            if attributes != nil {
                attributes = self.layoutAttributesForItem(at: itemIndexPath)
                attributes?.alpha = 0.0
                attributes?.center = CGPointMake(self.center.x, self.center.y)
            }
        }
        
        
        return attributes
    }
    
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // Disappear animation
        var attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        
        if self.deleteIndexPaths?.contains(itemIndexPath) ?? false {
            if attributes != nil {
                attributes = self.layoutAttributesForItem(at: itemIndexPath)
                
                attributes?.alpha = 0.0
                attributes?.center = CGPointMake(self.center.x, self.center.y)
                attributes?.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
            }
        }
        
        return attributes
    }
    
    

}
