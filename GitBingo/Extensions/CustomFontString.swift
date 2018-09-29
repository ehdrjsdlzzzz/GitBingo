//
//  CustomFontString.swift
//  GitBingo
//
//  Created by 이동건 on 02/09/2018.
//  Copyright © 2018 이동건. All rights reserved.
//

import UIKit

extension String {
    var customFont: NSMutableAttributedString {
        let customString = NSMutableAttributedString(string: self)
        let ns = self as NSString
        customString.addAttributes([NSAttributedString.Key.font : UIFont(name: "Apple Color Emoji", size: 17) ?? .systemFont(ofSize: 10)], range: NSRange.init(location: 0, length: ns.length))
        return customString
    }
}
