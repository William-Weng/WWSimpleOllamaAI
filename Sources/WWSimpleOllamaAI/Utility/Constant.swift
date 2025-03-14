//
//  Constant.swift
//  WWSimpleOllamaAI
//
//  Created by William.Weng on 2025/2/11.
//

import UIKit

// MARK: - enum
public extension WWSimpleOllamaAI {
    
    /// [API功能](https://api-docs.deepseek.com/)
    enum API {
        
        case generate
        case chat
        
        /// 取得url
        /// - Returns: String
        public func url() -> String {
            
            let path: String
            
            switch self {
            case .generate: path = "api/generate"
            case .chat: path = "api/chat"
            }
            
            return "\(WWSimpleOllamaAI.baseURL)/\(path)"
        }
    }
    
    /// 角色類型
    enum Role: Codable {
        
        case user
        case assistant
        case custom(_ name: String)
        
        /// 角色名稱
        /// - Returns: String
        func name() -> String {
            switch self {
            case .user: return "user"
            case .assistant: return "assistant"
            case .custom(let name): return name
            }
        }
    }
    
    /// 結果回傳的格式
    enum ResponseType {
        case string(_ string: String? = nil)
        case data(_ data: Data? = nil)
        case ndjson(_ json: [Any]? = nil)
    }
    
    /// 要求AI要回傳的格式敘述
    enum ResponseFormat {
        
        case string(_ string: String)
        case json(_ json: String)
        
        /// 數值
        /// - Returns: String
        func value() -> String {
            switch self {
            case .string(let string): return "\"\(string)\""
            case .json(let json): return json
            }
        }
    }
    
    /// 要求AI的選項敘述
    enum ResponseOptions {
        
        case json(_ json: String)
        
        /// 數值
        /// - Returns: String
        func value() -> String {
            switch self {
            case .json(let json): return json
            }
        }
    }
    
    /// 要求AI的函式功能
    enum ResponseTools {
        
        case json(_ json: String)
        
        /// 數值
        /// - Returns: String
        func value() -> String {
            switch self {
            case .json(let json): return json
            }
        }
    }
    
    /// Ollama錯誤
    enum OllamaError: Error {
        
        case jsonString     // JSON格式編碼錯誤
        
        /// 錯誤訊息
        /// - Returns: String
        public func message() -> String {
            
            switch self {
            case .jsonString: return "JSON format encoding error."
            }
        }
    }
    
    /// [網頁檔案類型的MimeType](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
    enum MimeType {
        
        case jpeg(compressionQuality: CGFloat)
        case png
        case heic
    }
}
