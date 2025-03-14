//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2025/3/13.
//

import UIKit
import WWHUD
import WWEventSource
import WWSimpleOllamaAI

// MARK: - ViewController
final class ViewController: UIViewController {
    
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    private let baseURL = "http://localhost:11434"
    
    private var isDismiss = false
    private var response: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { await initLoadModelIntoMemory() }
    }
    
    @IBAction func generateDemo(_ sender: UIButton) {
        Task { await generate(prompt: "你好,請問今天天氣如何?") }
    }
    
    @IBAction func talkDemo(_ sender: UIButton) {
         Task { await talk(content: "您的模型是幾版的？") }
    }
    
    @IBAction func generateLiveDemo(_ sender: UIButton) {
        
        configure()
        displayHUD()
        
        let urlString = WWSimpleOllamaAI.API.generate.url()
        let json = """
        {
          "model": "\(WWSimpleOllamaAI.model)",
          "prompt": "請寫出一首五言詩",
          "stream": true
        }
        """
        
        _ = WWEventSource.shared.connect(httpMethod: .POST, delegate: self, urlString: urlString, httpBodyType: .string(json))
    }
}

// MARK: - WWEventSourceDelegate
extension ViewController: WWEventSource.Delegate {
    
    func serverSentEventsConnectionStatus(_ eventSource: WWEventSource, result: Result<WWEventSource.ConnectionStatus, any Error>) {
        sseStatusAction(eventSource: eventSource, result: result)
    }
    
    func serverSentEvents(_ eventSource: WWEventSource, rawString: String) {
        sseRawString(eventSource: eventSource, rawString: rawString)
    }
    
    func serverSentEvents(_ eventSource: WWEventSource, eventValue: WWEventSource.EventValue) {
        print(eventValue)
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 先將模型載入記憶體中
    func initLoadModelIntoMemory() async {
        
        displayHUD()
        configure()
        
        let result = await WWSimpleOllamaAI.shared.loadIntoMemory(api: .generate)
        
        switch result {
        case .failure(let error): displayText(error)
        case .success(let responseType): diplayResponse(type: responseType)
        }
        
        WWHUD.shared.dismiss()
    }
        
    /// 生成文本回應
    /// - Parameters:
    ///   - prompt: 提問文字
    func generate(prompt: String) async {
        
        displayHUD()

        let result = await WWSimpleOllamaAI.shared.generate(prompt: prompt, type: .string())
        
        switch result {
        case .failure(let error): displayText(error)
        case .success(let responseType): diplayResponse(type: responseType)
        }
        
        WWHUD.shared.dismiss()
    }
    
    /// 聊天對談
    /// - Parameter content: 提問
    func talk(content: String) async {
        
        displayHUD()
        
        let result = await WWSimpleOllamaAI.shared.talk(content: content)
        
        switch result {
        case .failure(let error): displayText(error)
        case .success(let responseType): diplayResponse(type: responseType)
        }
        
        WWHUD.shared.dismiss()
    }
}

// MARK: - 小工具
private extension ViewController {
    
    /// 設定模型
    func configure() {
        guard let model = modelTextField.text else { return }
        WWSimpleOllamaAI.configure(baseURL: baseURL, model: model)
    }
    
    /// 顯示AI回應
    /// - Parameter type: WWSimpleOllamaAI.ResponseType
    func diplayResponse(type: WWSimpleOllamaAI.ResponseType) {
        
        switch type {
        case .string(let string): displayText(string)
        case .data(let data): displayText(data)
        case .ndjson(let ndjson): displayText(ndjson)
        }
    }
    
    /// 顯示HUD
    func displayHUD() {
        guard let gifUrl = Bundle.main.url(forResource: "Loading", withExtension: ".gif") else { return }
        WWHUD.shared.display(effect: .gif(url: gifUrl, options: nil), height: 256.0, backgroundColor: .black.withAlphaComponent(0.3))
    }
    
    /// 顯示文字
    /// - Parameter value: Any?
    @MainActor
    func displayText(_ value: Any?) {
        resultTextView.text = "\(value ?? "")"
    }
}

// MARK: - SSE (Server Sent Events - 單方向串流)
private extension ViewController {
    
    /// SSE狀態處理
    /// - Parameters:
    ///   - eventSource: WWEventSource
    ///   - result: Result<WWEventSource.Constant.ConnectionStatus, any Error>
    func sseStatusAction(eventSource: WWEventSource, result: Result<WWEventSource.ConnectionStatus, any Error>) {
        
        switch result {
        case .failure(_):
            
            DispatchQueue.main.async { [unowned self] in
                WWHUD.shared.dismiss();
                isDismiss = true
                response = ""
            }
            
        case .success(let status):
                        
            switch status {
            case .connecting: isDismiss = false
            case .open: if !isDismiss { DispatchQueue.main.async { [unowned self] in WWHUD.shared.dismiss(); isDismiss = true }}
            case .closed: response = ""; isDismiss = false
            }
        }
    }
    
    /// SSE資訊處理
    /// - Parameters:
    ///   - eventSource: WWEventSource
    ///   - rawString: String
    func sseRawString(eventSource: WWEventSource, rawString: String) {
        
        guard let jsonObject = rawString._data()?._jsonObject() as? [String: Any],
              let _response = jsonObject["response"] as? String
        else {
            return
        }
        
        response += _response
        
        DispatchQueue.main.async { [unowned self] in
            resultTextView.text = response
            resultTextView._autoScrollToBottom()
        }
    }
}
