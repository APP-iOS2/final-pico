//
//  StorageService.swift
//  Pico
//
//  Created by LJh on 10/6/23.
//

import UIKit
import RxSwift
import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

final class StorageService {
    static let shared: StorageService = StorageService()
    private let storageRef = Storage.storage()
    func uploadImages(images: [UIImage], userId: String) -> Observable<[String]> {
        return Observable.create { observer in
            Task.init {
                var urlStrings: [String] = []
                
                for (index, image) in images.enumerated() {
                    guard let imageData = image.jpegData(compressionQuality: 0.5) else { continue }
                    let imageRef = self.storageRef.reference().child("userImage/\(userId)/image\(index)")
                    
                    do {
                        _ = try await imageRef.putDataAsync(imageData)
                        let url = try await imageRef.downloadURL()
                        urlStrings.append(url.absoluteString)
                    } catch {
                        observer.onError(error)
                        return
                    }
                }
                
                observer.onNext(urlStrings)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    func getUrlStrings(images: [UIImage], userId: String) -> Observable<[String]> {
        let urlStrings = uploadImages(images: images, userId: userId)
        
        return urlStrings
    }
}
