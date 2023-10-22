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

enum Collections {
    case users
    case likes
    case notifications
    case mail
    case payment
    case tokens
    case unsubscribe
    case report
    case block
    
    var name: String {
        switch self {
        case .users:
            return "users"
        case .likes:
            return "likes"
        case .notifications:
            return "notifications"
        case .mail:
            return "mail"
        case .payment:
            return "payment"
        case .tokens:
            return "tokens"
        case .unsubscribe:
            return "unsubscribe"
        case .report:
            return "Report"
        case .block:
            return "Block"
        }
    }
}

final class FirestoreService {
    static let shared: FirestoreService = FirestoreService()
    
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
    
    func saveDocument<T: Codable>(collectionId: Collections, documentId: String, data: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global().async {
            do {
                try self.dbRef.collection(collectionId.name).document(documentId).setData(from: data.self)
                completion(.success(true))
                
                print("Success to save new document at \(collectionId.name) \(documentId)")
            } catch {
                print("Error to save new document at \(collectionId.name) \(documentId) \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func saveDocument<T: Codable>(collectionId: Collections, documentId: String, fieldId: String, data: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.global().async {
            self.dbRef.collection(collectionId.name).document(documentId)
                .setData([fieldId: FieldValue.arrayUnion([data.asDictionary()])], merge: true) { error in
                    if let error = error {
                        print("Error to save new document at \(collectionId.name) \(documentId) \(error)")
                        completion(.failure(error))
                    } else {
                        completion(.success(true))
                        print("Success to save new document at \(collectionId.name) \(documentId)")
                    }
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
    
    func searchDocumentWithEqualField<T: Codable>(collectionId: Collections, field: String, compareWith: Any, dataType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        DispatchQueue.global().async {
            let query = self.dbRef.collection(collectionId.name).whereField(field, isEqualTo: compareWith)
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error in query: \(error)")
                    completion(.failure(error))
                    return
                }
                
                if querySnapshot?.documents.isEmpty == true {
                    print("At \(collectionId.name) document is Empty")
                    completion(.success([]))
                } else {
                    var result: [T] = []
                    for document in querySnapshot!.documents {
                        if let temp = try? document.data(as: dataType) {
                            result.append(temp)
                        }
                    }
                    completion(.success(result))
                }
            }
        }
    }
    
    func loadDocuments<T: Codable>(collectionId: Collections, dataType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) {
        
        let query = dbRef.collection(collectionId.name)
            .order(by: "createdDate", descending: true)
        
        DispatchQueue.global().async {
            query.getDocuments { querySnapshot, error in
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
    
    func loadDocuments<T: Codable>(collectionId: Collections, dataType: T.Type, orderBy: (String, Bool), itemsPerPage: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping (Result<([T], DocumentSnapshot?), Error>) -> Void) {
        var lastDocumentSnapshot = lastDocumentSnapshot
        
        let query = dbRef.collection(collectionId.name)
            .order(by: orderBy.0, descending: orderBy.1)
            .limit(to: itemsPerPage)
        
        if let lastSnapshots = lastDocumentSnapshot {
            query.start(afterDocument: lastSnapshots)
        }
        
        DispatchQueue.global().async {
            query.getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error to load new document at \(collectionId.name) \(error)")
                    completion(.failure(error))
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                guard !documents.isEmpty else { return }
                
                lastDocumentSnapshot = documents.last
                
                if let documents = querySnapshot?.documents {
                    var result: [T] = []
                    for document in documents {
                        if let temp = try? document.data(as: dataType) {
                            result.append(temp)
                        }
                    }
                    completion(.success((result, lastDocumentSnapshot)))
                }
            }
        }
    }
    
    func updateDocument<T: Codable>(collectionId: Collections, documentId: String, field: String, data: T, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            dbRef.collection(collectionId.name).document(documentId).updateData([field: data]) { err in
                if let err = err {
                    completion(.failure(err))
                    print("Error updating document: \(err)")
                } else {
                    completion(.success(data))
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func updataDocuments<T: Codable>(collectionId: Collections, documentId: String, field: String, data: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        let jsonData = data.asDictionary()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            dbRef.collection(collectionId.name).document(documentId).updateData([field: jsonData]) { error in
                if let error = error {
                    completion(.failure(error))
                    print("Error updating document: \(error)")
                } else {
                    completion(.success(true))
                    print("Document successfully updated")
                }
            }
        }
    }
    
    func removeDocument(collectionId: Collections, documentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            dbRef.collection(collectionId.name).document(documentId).delete { err in
                if let err = err {
                    completion(.failure(err))
                    print("Error updating document: \(err)")
                } else {
                    completion(.success(()))
                    print("Document successfully updated")
                }
            }
        }
    }
    
    // MARK: - Rx
    func saveDocumentRx<T: Codable>(collectionId: Collections, documentId: String, data: T) -> Observable<Void> {
        return Observable.create { emitter in
            self.saveDocument(collectionId: collectionId, documentId: documentId, data: data) { result in
                switch result {
                case .success(let bool):
                    if bool {
                        emitter.onNext(())
                        emitter.onCompleted()
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func saveDocumentRx<T: Codable>(collectionId: Collections, documentId: String, fieldId: String, data: T) -> Observable<Void> {
        return Observable.create { emitter in
            self.saveDocument(collectionId: collectionId, documentId: documentId, fieldId: fieldId, data: data) { result in
                switch result {
                case .success(let bool):
                    if bool {
                        emitter.onNext(())
                        emitter.onCompleted()
                    }
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
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
    
    func loadDocumentRx<T: Codable>(collectionId: Collections, dataType: T.Type, orderBy: (String, Bool), itemsPerPage: Int, lastDocumentSnapshot: DocumentSnapshot?) -> Observable<([T], DocumentSnapshot?)> {
        return Observable.create { emitter in
            self.loadDocuments(collectionId: collectionId, dataType: dataType, orderBy: orderBy, itemsPerPage: itemsPerPage, lastDocumentSnapshot: lastDocumentSnapshot) { result in
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
    
    func updateDocumentRx<T: Codable>(collectionId: Collections, documentId: String, field: String, data: T) -> Observable<T> {
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            updateDocument(collectionId: collectionId, documentId: documentId, field: field, data: data) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func searchDocumentWithEqualFieldRx<T: Codable>(collectionId: Collections, field: String, compareWith: Any, dataType: T.Type) -> Observable<[T]> {
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            searchDocumentWithEqualField(collectionId: collectionId, field: field, compareWith: compareWith, dataType: dataType) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func removeDocumentRx(collectionId: Collections, documentId: String) -> Observable<Void> {
        return Observable.create { [weak self] emitter in
            guard let self = self else { return Disposables.create() }
            removeDocument(collectionId: collectionId, documentId: documentId) { result in
                switch result {
                case .success:
                    emitter.onNext(())
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
