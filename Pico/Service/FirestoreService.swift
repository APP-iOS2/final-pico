//
//  FirestoreService.swift
//  Pico
//
//  Created by 최하늘 on 10/4/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxSwift

enum Collections: CaseIterable {
    case users
    case notifications
    
    var name: String {
        switch self {
        case .users:
            return "users"
        case .notifications:
            return "notifications"
        }
    }
}

final class FirestoreService {
    private let dbRef = Firestore.firestore()
    
    func saveDocument<T: Codable>(collectionId: Collections, data: T) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            do {
                try dbRef.collection(collectionId.name).addDocument(from: data.self)
                print("Success to save new document at collection \(collectionId.name)")
            } catch {
                print("Error to save new document: \(error)")
            }
        }
    }
    
    func saveDocument<T: Codable>(collectionId: Collections, documentId: String, data: T) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            do {
                try dbRef.collection(collectionId.name).document(documentId).setData(from: data.self)
                print("Success to save new document at \(collectionId.name) \(documentId)")
            } catch {
                print("Error to save new document at \(collectionId.name) \(documentId) \(error)")
            }
        }
    }
    
    func loadDocument<T: Codable>(collectionId: Collections, documentId: String, dataType: T.Type, completion: @escaping (Result<T?, Error>) -> Void) {
        DispatchQueue.global().async {
            self.dbRef.collection(collectionId.name).document(documentId).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error to load new document at \(collectionId.name) \(documentId) \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        let documentData = try snapshot.data(as: dataType)
                        print("Success to load new document at \(collectionId.name) \(documentId)")
                        completion(.success(documentData))
                    } catch {
                        print("Error to decode document data: \(error)")
                        completion(.failure(error))
                    }
                } else {
                    completion(.success(nil))
                }
            }
        }
    }
    
    func searchDocumentWithEqualField<T: Codable>(collectionId: Collections, field: String, compareWith: Any, completion: @escaping (Result<[T]?, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let query = dbRef.collection(collectionId.name).whereField(field, isEqualTo: compareWith)
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error in query: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if querySnapshot?.documents.isEmpty == true {
                    print("At \(collectionId.name) document is Empty")
                    completion(.success(nil))
                } else {
                    var result: [T] = []
                    for document in querySnapshot!.documents {
                        if let temp = try? document.data(as: T.self) {
                            result.append(temp)
                        }
                    }
                    completion(.success(result))
                }
            }
        }
    }
    
    func loadDocuments<T: Codable>(collectionId: Collections, dataType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        DispatchQueue.global().async {
            
            self.dbRef.collection(collectionId.name).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error to load new document at \(collectionId.name) \(error)")
                    completion(.failure(error))
                    return
                }
                
                if let documents = querySnapshot?.documents {
                    var result: [T] = []
                    for document in documents {
                        if let temp = try? document.data(as: dataType) {
                            result.append(temp)
                        }
                    }
                    completion(.success(result))
                }
            }
        }
    }
    
    func loadDocumentRx<T: Codable>(collectionId: Collections, dataType: T.Type) -> Observable<[T]> {
        return Observable.create { emitter in
            self.loadDocuments(collectionId: collectionId, dataType: dataType) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func loadDocumentRx<T: Codable>(collectionId: Collections, documentId: String, dataType: T.Type) -> Observable<T?> {
        return Observable.create { emitter in
            self.loadDocument(collectionId: collectionId, documentId: documentId, dataType: dataType) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
