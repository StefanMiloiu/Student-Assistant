//
//  Injection.swift
//  Student Assistant
//
//  Created by Stefan Miloiu on 12.10.2024.
//

import Foundation
import Swinject

final class Injection {
    static let shared = Injection()
    var container: Container {
        get {
            if _container == nil {
                _container = buildContainer()
            }
            return _container!
        }
        set {
            _container = newValue
        }
    }
    
    private var _container: Container?
    private init() {}
    
    private func buildContainer() -> Container {
        let container = Container()
        container.register(DataManagerProtocol.self) { _ in DataManager.shared }
        container.register(AssignmentRepo.self) { r in AssignmentRepo(dataManager: r.resolve(DataManagerProtocol.self)!) }
        container.register(ExamRepo.self) { r in ExamRepo(dataManager: r.resolve(DataManagerProtocol.self)!)}
        container.register(AssignmentListViewModel.self) { r in AssignmentListViewModel(assignmentRepo: r.resolve(AssignmentRepo.self)!)}
        return container
    }
}
