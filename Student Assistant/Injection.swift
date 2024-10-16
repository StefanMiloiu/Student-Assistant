//
//  Injection.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import Swinject

/*
 The `Injection` class is responsible for dependency injection using Swinject.
 It ensures that various services and repositories are registered and resolved
 when needed, promoting loose coupling and easier testing.
*/
final class Injection {
    
    /*
     A shared singleton instance of `Injection`, allowing it to be accessed globally.
    */
    static let shared = Injection()
    
    /*
     A computed property that lazily initializes and provides access to the Swinject `Container`.
     The container holds the registered services and resolves them upon request.
    */
    var container: Container {
        get {
            if _container == nil {
                _container = buildContainer() // Build the container if it hasn't been initialized
            }
            return _container!
        }
        set {
            _container = newValue
        }
    }
    
    /*
     Private variable to store the Swinject container. It starts as nil
     and gets initialized when needed.
    */
    private var _container: Container?
    
    /*
     Private initializer to prevent external instantiation of this class.
     This ensures the class follows the singleton pattern.
    */
    private init() {}
    
    // MARK: - Container Setup
    
    /*
     Builds the Swinject container by registering dependencies for various services and repositories.
     This function ensures that the correct instances are injected where needed.
     
     - Returns: A fully initialized Swinject `Container` with all the necessary dependencies registered.
    */
    private func buildContainer() -> Container {
        let container = Container()
        
        // Registering DataManagerProtocol as a shared instance of DataManager
        container.register(DataManagerProtocol.self) { _ in DataManager.shared }
        
        // Registering the AssignmentRepo, which depends on the DataManagerProtocol
        container.register(AssignmentRepo.self) { r in
            AssignmentRepo(dataManager: r.resolve(DataManagerProtocol.self)!)
        }
        
        // Registering the ExamRepo, which also depends on the DataManagerProtocol
        container.register(ExamRepo.self) { r in
            ExamRepo(dataManager: r.resolve(DataManagerProtocol.self)!)
        }
        
        // Registering the TrackTimeRepo, which depends on the DataManagerProtocol
        container.register(TrackTimeRepo.self) { r in
            TrackTimeRepo(dataManager: r.resolve(DataManagerProtocol.self)!)
        }
        
        // Registering the AssignmentListViewModel, which depends on the AssignmentRepo
        container.register(AssignmentListViewModel.self) { r in
            AssignmentListViewModel(assignmentRepo: r.resolve(AssignmentRepo.self)!)
        }

        return container // Return the constructed container
    }
}

