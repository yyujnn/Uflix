//
//  MainViewModel.swift
//  Uflix
//
//  Created by 정유진 on 5/13/25.
//

import Foundation

class MainViewModel {
    
    private var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String else {
            fatalError("TMDB_API_KEY not found in Info.plist")
        }
        return apiKey
    }
    
    init() {
        
    }
    
    func fetchPopularMovie() {
        
    }
 
    func fetchTopRatedMovie() {
        
    }
    
    func fetchUpComingMovie() {
        
    }
}
