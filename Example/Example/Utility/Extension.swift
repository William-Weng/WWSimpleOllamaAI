//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2025/3/13.
//

import UIKit

// MARK: - String (function)
extension String {
    
    /// String => Data
    /// - Parameters:
    ///   - encoding: 字元編碼
    ///   - isLossyConversion: 失真轉換
    /// - Returns: Data?
    func _data(using encoding: String.Encoding = .utf8, isLossyConversion: Bool = false) -> Data? {
        let data = self.data(using: encoding, allowLossyConversion: isLossyConversion)
        return data
    }
}

// MARK: - Data (function)
extension Data {
    
    /// [Data => JSON](https://blog.zhgchg.li/現實使用-codable-上遇到的-decode-問題場景總匯-下-cb00b1977537)
    /// - 7b2268747470223a2022626f6479227d => {"http": "body"}
    /// - Returns: Any?
    func _jsonObject(options: JSONSerialization.ReadingOptions = .allowFragments) -> Any? {
        let json = try? JSONSerialization.jsonObject(with: self, options: options)
        return json
    }
}

// MARK: - UITextView (function)
extension UITextView {
    
    /// 自動向下移動
    func _autoScrollToBottom() {
        
        let count = text.count
        guard count > 0 else { return }
        
        let bottom = NSMakeRange(count - 1, 1)
        scrollRangeToVisible(bottom)
    }
}
