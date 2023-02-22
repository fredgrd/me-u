//
//  DeepLinkManager.swift
//  me&u
//
//  Created by Federico on 18/02/23.
//

import Foundation
import Combine

final class DeeplinkManager {
    
    struct Info {
        let host: String
        let parameters: [String: String]
    }
    
    static let shared = DeeplinkManager()
    
    let urlToOpen = CurrentValueSubject<Info?, Never>(nil)
    
    private init() {
    
    }
    
    func openUrl(_ url: URL) {
        print("OPENING URL",url.absoluteString)
        print(url.pathComponents, url.host())
        
        guard let host = url.host() else {
            return
        }
        
        var parameters: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }

        let info = Info(host: host, parameters: parameters)
        
        urlToOpen.send(info)
    }
    
    
}
