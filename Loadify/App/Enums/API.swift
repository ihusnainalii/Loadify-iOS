//
//  Endpoint.swift
//  Loadify
//
//  Created by Vishweshwaran on 11/09/22.
//

import Foundation

enum API {
    case details(youtubeURL: String)
    case download(youtubeURL: String, quality: VideoQuality)
}

extension API: NetworkRequestable {
    
    var host: String {
        "loadify.madrasvalley.com"
    }
    
    var path: String {
        switch self {
        case .details:
            return "/api/yt/details"
        case .download:
            return "/api/yt/download/video/mp4"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .details, .download:
            return .get
        }
    }
    
    var queryParameters: [String : AnyHashable]? {
        switch self {
        case .details(let url):
            return ["url": url]
        case .download(let url, let quality):
            return ["url": url, "video_quality": quality.rawValue]
        }
    }
    
    /// Configuration for `localhost`
    var shouldRunLocal: Bool { false }
    
    var port: Int? { 3200 }
}
