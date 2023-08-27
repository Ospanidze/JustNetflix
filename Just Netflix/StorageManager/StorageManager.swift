//
//  StorageManager.swift
//  Just Netflix
//
//  Created by Айдар Оспанов on 27.08.2023.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NetflixModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    //MARK: -CRUD create read update delete
    func create(_ title: Title) {
        let titleItem = TitleItem(context: context)
        titleItem.originalName = title.originalName
        titleItem.originalTitle = title.originalTitle
        titleItem.overview = title.overview
        titleItem.posterPath = title.posterPath
        titleItem.id = Int64(title.id)
        titleItem.mediaType?.movie = title.mediaType?.rawValue
        titleItem.mediaType?.tv = title.mediaType?.rawValue
        titleItem.releaseDate = title.releaseDate
        titleItem.voteCount = Int64(title.voteCount)
        titleItem.voteAverage = title.voteAverage
        //completion(titleItem)
        saveContext()
    }
    
    func fetchData(completion: @escaping(Result<[TitleItem], Error>) -> Void) {
        let fetchRequest = TitleItem.fetchRequest()
        
        do {
            let titleItems = try context.fetch(fetchRequest)
            completion(.success(titleItems))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func update(_ titleItem: TitleItem, title: Title) {
        
    }
    
    func delete(_ titleItem: TitleItem) {
        context.delete(titleItem)
        saveContext()
    }
    
    //MARK: Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
