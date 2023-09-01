//
//  ImageView.swift
//  ChatroomUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit
import Combine

@objc final public class ImageView: UIImageView {

    private var cancellables = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func image(with url: String,placeHolder: UIImage?) {
        self.image = placeHolder
        guard let imageURL = URL(string: url) else { return }
        ImageLoader.shared.loadImage(from: imageURL)
            .sink(receiveValue: { [weak self] url_image in
                self?.image = url_image
            })
            .store(in: &self.cancellables)
    }

}
