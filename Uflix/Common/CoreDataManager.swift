//
//  CoreDataManager.swift
//  Uflix
//
//  Created by 정유진 on 5/19/25.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}

    func saveFavorite(movie: Movie) {
        let favorite = FavoriteMovie(context: context)
        favorite.id = Int64(movie.id)
        favorite.title = movie.title
        favorite.posterPath = movie.posterPath
        favorite.overview = movie.overview
        favorite.savedDate = Date()
        
        saveContext()
    }
    
    func isFavorite() {
        
    }
    
    func deleteFavorite() {
        
    }
    func saveContext() {
        
    }
    
}
