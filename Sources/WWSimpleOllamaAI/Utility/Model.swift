//
//  Model.swift
//  WWSimpleOllamaAI
//
//  Created by William.Weng on 2025/3/13.
//

import UIKit

// MARK: - Model
public extension WWSimpleOllamaAI {
    
    /// Chat的訊息格式 (roleType不參與Decodable)
    public class MessageInformation: Codable {
        
        var content: String
        var role: String
        var roleType: Role = .user
        
        public init(roleType: Role, content: String) {
            self.roleType = roleType
            self.role = roleType.name()
            self.content = content
        }
        
        enum CodingKeys: String, CodingKey {
            case role
            case content
        }
    }
}
