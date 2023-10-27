//
//  AvatarCreatorSettings.swift
//  Example-iOS-Swift
//
//  Created by Max Andreassen on 29/09/2023.
//  Copyright © 2023 Ready Player Me. All rights reserved.
//

import Foundation

enum Expression: String {
    case DEFAULT = ""
    case HAPPY = "happy"
    case LAUGHING = "lol"
    case SAD = "sad"
    case SCARED = "scared"
    case RAGE = "rage"
}

enum Pose: String {
    case DEFAULT = ""
    case THUMBS_UP = "thumbs-up"
    case POWER_STANCE = "power-stance"
    case RELAXED = "relaxed"
    case STANDING = "standing"
}

enum Camera: String {
    case DEFAULT = ""
    case PORTRAIT = "portrait"
    case FULLBODY = "fullbody"
}

struct Avatar2DRenderConfig {
    var expression: Expression = .DEFAULT
    var pose: Pose = .DEFAULT
    var camera: Camera = .DEFAULT
    var quality: Int = 100
    var size: Int = 512
    var background: String = "144,89,156" //RGB values separated by commas
}

class Avatar2DRenderSettings {
    private let config: Avatar2DRenderConfig
    
    init(config: Avatar2DRenderConfig) {
        self.config = config
    }
    
    init() {
        self.config = Avatar2DRenderConfig()
    }
    
    func generateUrl(avatarUrl: String) -> URL {
        var url = avatarUrl.replacingOccurrences(of: ".glb", with: ".png?");
        
        if (config.expression != .DEFAULT) {
            url += "expression=\(config.expression.rawValue)&"
        }
        
        if (config.pose != .DEFAULT) {
            url += "pose=\(config.pose.rawValue)&"
        }
        
        if (config.camera != .DEFAULT) {
            url += "camera=\(config.camera.rawValue)&"
        }
        
        if (!(config.background).isEmpty) {
            url += "background=\(config.background)&"
        }
        
        url += "quality=\(config.quality)&"
        url += "size=\(config.size)&"
        
        return URL(string: url)!
    }
}
