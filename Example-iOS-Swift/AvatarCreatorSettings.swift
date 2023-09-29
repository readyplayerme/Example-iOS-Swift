//
//  AvatarCreatorSettings.swift
//  Example-iOS-Swift
//
//  Created by Max Andreassen on 29/09/2023.
//  Copyright © 2023 Wolf3D. All rights reserved.
//

import Foundation

enum Language: String {
    case DEFAULT = ""
    case CHINESE = "ch"
    case GERMAN = "de"
    case ENGLISH_IRELAND = "en-IE"
    case ENGLISH = "en"
    case SPANISH_MEXICO = "es-MX"
    case SPANISH = "es"
    case FRENCH = "fr"
    case ITALIAN = "it"
    case JAPANESE = "jp"
    case KOREAN = "kr"
    case PORTUGAL_BRAZIL = "pt-BR"
    case PORTUGESE = "pt"
    case TURKISH = "tr"
}

enum BodyType: String {
    case SELECTABLE = ""
    case FULLBODY = "fullbody"
    case HALFBODY = "halfbody"
}

enum Gender: String {
    case NONE = ""
    case MALE = "male"
    case FEMALE = "female"
}

struct AvatarCreatorConfig {
    // Update to your subdomain URL here
    var subdomain: String = "demo"
    var clearCache: Bool = false
    var quickStart: Bool = false
    var gender: Gender = .MALE
    var bodyType: BodyType = .SELECTABLE
    var loginToken: String = ""
    var language: Language = .DEFAULT
}

class AvatarCreatorSettings {
    private let config: AvatarCreatorConfig
    
    init(config: AvatarCreatorConfig) {
        self.config = config
    }
    
    init() {
        self.config = AvatarCreatorConfig()
    }
    
    func generateUrl() -> URL {
        var url = "https://\(config.subdomain).readyplayer.me/"
        
        if (config.language != .DEFAULT) {
            url += "\(config.language.rawValue)/"
        }
        
        url += "avatar?frameApi"
        
        if (config.clearCache) {
            url += "&clearCache"
        }
        
        if (!config.loginToken.isEmpty) {
            url += "&token=\(config.loginToken)"
        }
        
        if (config.quickStart) {
            url += "&quickStart"
        }
        
        if (!config.quickStart && config.gender != .NONE) {
            url += "&gender=\(config.gender.rawValue)"
        }
        
        if (!config.quickStart && config.bodyType == .SELECTABLE) {
            url += "&selectBodyType"
        }
        
        if (!config.quickStart && config.bodyType != .SELECTABLE) {
            url += "&bodyType=\(config.bodyType.rawValue)"
        }
        
        return URL(string: url)!
    }
}
