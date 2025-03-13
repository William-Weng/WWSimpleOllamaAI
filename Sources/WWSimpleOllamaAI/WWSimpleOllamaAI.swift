//
//  WWSimpleOllamaAI.swift
//  WWSimpleOllamaAI
//
//  Created by William.Weng on 2025/3/13.
//

import UIKit
import WWNetworking

// MARK: - [簡單的Ollama功能使用](https://ollama.com/)
open class WWSimpleOllamaAI {
    
    @MainActor
    public static let shared = WWSimpleOllamaAI()
    
    private(set) public static var baseURL = "http://localhost:11434/"
    private(set) public static var model: String = "gemma:2b"
    
    private init() {}
}

// MARK: - 初始值設定 (static function)
public extension WWSimpleOllamaAI {
    
    /// [參數設定](https://ollama.com/)
    /// - Parameters:
    ///   - apiKey: String
    ///   - version: String
    ///   - model: Gemini模型
    static func configure(baseURL: String, model: String) {
        Self.baseURL = baseURL
        Self.model = model
    }
}

// MARK: - 公開函式
public extension WWSimpleOllamaAI {
    
    /// [生成文本回應](https://github.com/ollama/ollama)
    /// - Parameters:
    ///   - prompt: 提問
    ///   - type: 回應樣式 => String / Data / JSON
    ///   - format: 回應樣式格式化
    ///   - useStream: 是否使用串流回應
    ///   - encoding: 文字編碼
    /// - Returns: Result<String?, Error>
    func generate(prompt: String, type: ResponseType = .string(), format: ResponseFormat? = nil, useStream: Bool = false, using encoding: String.Encoding = .utf8) async -> Result<ResponseType, Error> {
        
        let api = API.generate
        let format = format?.value() ?? "\"\""
        
        var json = """
        {
          "model": "\(Self.model)",
          "prompt": "\(prompt)",
          "stream": \(useStream),
          "format": \(format)
        }
        """
                
        let result = await WWNetworking.shared.request(httpMethod: .POST, urlString: api.url(), headers: nil, httpBodyType: .string(json))
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info): return .success(parseResponseInformation(info, api: api, forType: type, using: encoding))
        }
    }
    
    /// [聊天對話](https://github.com/ollama/ollama/blob/main/docs/api.md)
    /// - Parameters:
    ///   - message: [提問](https://dribbble.com/shots/22339104-Crab-Loading-Gif)
    ///   - type: 回應樣式 => String / Data / JSON
    ///   - useStream: 是否使用串流回應
    ///   - encoding: 文字編碼
    func chat(message: MessageInformation, type: ResponseType = .string(), useStream: Bool = false, using encoding: String.Encoding = .utf8) async -> Result<ResponseType, Error> {
        
        guard let _jsonString = [message]._jsonString(using: encoding) else { return .failure(OllamaError.jsonString) }
        
        let api = API.chat
        let json = """
        {
          "model": "\(Self.model)",
          "messages": \(_jsonString),
          "stream": \(useStream)
        }
        """
                
        let result = await WWNetworking.shared.request(httpMethod: .POST, urlString: api.url(), headers: nil, httpBodyType: .string(json))
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info): return .success(parseResponseInformation(info, api: api, forType: type, using: encoding))
        }
    }
}

// MARK: - 小工具
private extension WWSimpleOllamaAI {
    
    /// 解析回應格式 => String / Data / JSON
    /// - Parameters:
    ///   - info: WWNetworking.ResponseInformation
    ///   - type: ResponseType
    ///   - encoding: String.Encoding
    /// - Returns: ResponseType
    func parseResponseInformation(_ info: WWNetworking.ResponseInformation, api: API, forType type: ResponseType, using encoding: String.Encoding) -> ResponseType {
        
        let data = info.data
        
        switch type {
        case .string: return .string(combineResponseString(api: api, data: data, using: encoding))
        case .data(_): return .data(data)
        case .ndjson(_): return .ndjson(data?._ndjson(using: encoding))
        }
    }

    /// [結合回應字串](https://zh.pngtree.com/freebackground/ai-artificial-intelligent-blue_961916.html)
    /// - Parameters:
    ///   - data: Data?
    ///   - encoding: String.Encoding
    /// - Returns: String?
    func combineResponseString(api: API, data: Data?, using encoding: String.Encoding = .utf8) -> String? {
        
        guard let jsonArray = data?._ndjson(using: encoding) else { return nil }
        
        var string: String = ""
        
        switch api {
        case .generate:
            
            jsonArray.forEach { json in
                
                guard let dict = json as? [String: Any],
                      let response = dict["response"] as? String
                else {
                    return
                }
                
                string += response
            }
            
        case .chat:
            
            jsonArray.forEach { json in
                
                guard let dict = json as? [String: Any],
                      let message = dict["message"] as? [String: Any],
                      let content = message["content"] as? String
                else {
                    return
                }
                
                string += content
            }
        }
        
        return string
    }
}
