//
//  SearchHistoryManager.swift
//  Uflix
//
//  Created by 정유진 on 5/23/25.
//

import Foundation

struct SearchHistoryManager {
    static let key = "searchHistory"
    
    static func load() -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    static func save(_ keyword: String) {
        var history = load()
        history.removeAll {$0 == keyword}
        history.insert(keyword, at:0)
        history = Array(history.prefix(10))
        UserDefaults.standard.set(history, forKey: key)
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
