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
    
    private init() {}

    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteMovie")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData 로드 실패: \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Saving error: \(error)")
            }
        }
    }
}

extension CoreDataManager {
    func saveFavorite(movie: Movie) {
        let favorite = FavoriteMovie(context: context)
        favorite.id = Int64(movie.id)
        favorite.title = movie.title
        favorite.posterPath = movie.posterPath
        favorite.overview = movie.overview
        favorite.savedDate = Date()
        
        saveContext()
    }
    
    func fetchFavorites() -> [FavoriteMovie] {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetch favorites: \(error)")
            return []
        }
    }
    
    func isFavorite(id: Int) -> Bool {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let result = try context.fetch(request)
            return !result.isEmpty
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }
    
    func deleteFavorite(id: Int) {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let favorites = try context.fetch(request)
            favorites.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Error deleting favorite: \(error)")
        }
    }
}
