# WWSimpleOllamaAI

[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWSimpleOllamaAI) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Simple connection to Ollama API functionality.](https://github.com/ollama/ollama/blob/main/docs/api.md)
- [簡單連接Ollama API。](https://dribbble.com/shots/22339104-Crab-Loading-Gif)

![](./Example.webp)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```
dependencies: [
    .package(url: "https://github.com/William-Weng/WWSimpleOllamaAI.git", .upToNextMajor(from: "0.6.1"))
]
```

## [Function - 可用函式](https://william-weng.github.io/2025/01/docker容器大家一起來當鯨魚搬運工吧/)
|函式|功能|
|-|-|
|configure(baseURL:model:jpegCompressionQuality:)|相關參數設定|
|loadIntoMemory(api:isLoad:type:using:)|載入模型到記憶體的設定 - 開 / 關|
|generate(prompt:type:timeout:format:options:images:useStream:using:)|一次性回應 - 每次請求都是獨立的|
|talk(content:type:timeout:format:useStream:options:images:tools:using:)|說話模式 - 會記住之前的對話內容|
|chat(messages:type:format:timeout:useStream:options:images:tools:using:)|對話模式 - 會記住之前的對話內容|

## [Example](https://ezgif.com/video-to-webp)
```swift
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
    
    @IBAction func chatDemo(_ sender: UIButton) {
         Task { await chat(content: "您的模型是幾版的？") }
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

private extension ViewController {
    
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
    
    func generate(prompt: String) async {
        
        displayHUD()

        let result = await WWSimpleOllamaAI.shared.generate(prompt: prompt, type: .string())
        
        switch result {
        case .failure(let error): displayText(error)
        case .success(let responseType): diplayResponse(type: responseType)
        }
        
        WWHUD.shared.dismiss()
    }
    
    func chat(content: String) async {
        
        displayHUD()
        
        let message: WWSimpleOllamaAI.MessageInformation = .init(roleType: .user, content: content)
        let result = await WWSimpleOllamaAI.shared.chat(message: message)
        
        switch result {
        case .failure(let error): displayText(error)
        case .success(let responseType): diplayResponse(type: responseType)
        }
        
        WWHUD.shared.dismiss()
    }
}

private extension ViewController {
    
    func configure() {
        guard let model = modelTextField.text else { return }
        WWSimpleOllamaAI.configure(baseURL: baseURL, model: model)
    }
    
    func diplayResponse(type: WWSimpleOllamaAI.ResponseType) {
        
        switch type {
        case .string(let string): displayText(string)
        case .data(let data): displayText(data)
        case .ndjson(let ndjson): displayText(ndjson)
        }
    }
    
    func displayHUD() {
        guard let gifUrl = Bundle.main.url(forResource: "Loading", withExtension: ".gif") else { return }
        WWHUD.shared.display(effect: .gif(url: gifUrl, options: nil), height: 256.0, backgroundColor: .black.withAlphaComponent(0.3))
    }
    
    @MainActor
    func displayText(_ value: Any?) {
        resultTextView.text = "\(value ?? "")"
    }
}

private extension ViewController {
    
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
```

