//
//  MainViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/13/25.
//

import Foundation

class MainViewModel {
    
    private let apiKey: String?
    
    init() {
        self.apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String
        print("✅ TMDB API Key: \(apiKey ?? "nil")")
    }
    
    func fetchData() {
        guard let apiKey = apiKey else {
            print("❌ API Key가 없습니다.")
            return
        }
        
        // API 호출에 apiKey 사용
        
    }
    
    func fetchPopularMovie() {
        
    }
 
    func fetchTopRatedMovie() {
        
    }
    
    func fetchUpComingMovie() {
        
    }
}
