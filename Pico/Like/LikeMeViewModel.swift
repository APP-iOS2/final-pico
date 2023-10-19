//
//  LikeViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/04.
//

import Foundation
import RxSwift
import RxRelay
import FirebaseFirestore

final class LikeMeViewModel: ViewModelType {
    enum LikeMeError: Error {
        case notFound
    }
    
    private var isEmptyPublisher = PublishSubject<Bool>()
    private let reloadTableViewPublisher = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private let currentUser: CurrentUser = UserDefaultsManager.shared.getUserData()
    
    private let dbRef = Firestore.firestore()
    private let pageSize = 6
    var startIndex = 0
    
    struct Input {
        let listLoad: Observable<Void>
        let refresh: Observable<Void>
        let deleteUser: Observable<String>
        let likeUser: Observable<String>
        let checkEmpty: Observable<Void>
    }
    
    struct Output {
        let likeUIsEmpty: Observable<Bool>
        let reloadCollectionView: Observable<Void>
    }
    
    private(set) var likeMeList: [Like.LikeInfo] = [] {
        didSet {
            if likeMeList.isEmpty {
                isEmptyPublisher.onNext(true)
            } else {
                isEmptyPublisher.onNext(false)
            }
        }
    }
    
    func transform(input: Input) -> Output {
        input.refresh
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.refresh()
            }
            .disposed(by: disposeBag)
        input.listLoad
            .withUnretained(self)
            .subscribe { viewModel, _ in
                viewModel.loadNextPage()
            }
            .disposed(by: disposeBag)
        input.deleteUser
            .withUnretained(self)
            .subscribe { viewModel, userId in
                viewModel.deleteUser(userId: userId)
            }
            .disposed(by: disposeBag)
        input.likeUser
            .withUnretained(self)
            .subscribe { viewModel, userId in
                viewModel.likeUser(userId: userId)
            }
            .disposed(by: disposeBag)
        let didset = isEmptyPublisher.asObservable()
            .map { result in
                return result
            }
        let check = input.checkEmpty
            .withUnretained(self)
            .map { viewModel, _ -> Bool in
                if viewModel.likeMeList.isEmpty {
                    return true
                } else {
                    return false
                }
            }
        let isEmpty = Observable.of(didset, check).merge()
            .flatMapLatest { bool -> Observable<Bool> in
                return Observable.create { emitter in
                    emitter.onNext(bool)
                    return Disposables.create()
                }
            }
        
        return Output(likeUIsEmpty: isEmpty, reloadCollectionView: reloadTableViewPublisher.asObservable())
    }
    
    private func loadNextPage() {
        let dbRef = Firestore.firestore()
        let ref = dbRef.collection(Collections.likes.name).document(currentUser.userId)
        let endIndex = startIndex + pageSize
        
        DispatchQueue.global().async {
            ref.getDocument { [weak self] document, error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                    return
                }
                
                if let document = document, document.exists {
                    if let datas = try? document.data(as: Like.self).recivedlikes?.filter({ $0.likeType == .like }) {
                        if startIndex > datas.count - 1 {
                            return
                        }
                        let currentPageDatas: [Like.LikeInfo] = Array(datas[startIndex..<min(endIndex, datas.count)])
                        likeMeList.append(contentsOf: currentPageDatas)
                        startIndex += currentPageDatas.count
                        reloadTableViewPublisher.onNext(())
                    }
                } else {
                    print("문서를 찾을 수 없습니다.")
                }
            }
        }
    }
    
    private func refresh() {
        let didSet = isEmptyPublisher
        isEmptyPublisher = PublishSubject<Bool>()
        self.likeMeList = []
        self.startIndex = 0
        isEmptyPublisher = didSet
        loadNextPage()
    }
 
    private func deleteUser(userId: String) {
        guard let index = likeMeList.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        guard let removeData: Like.LikeInfo = likeMeList[safe: index] else {
            print("삭제 실패: 해당 유저 정보 얻기 실패")
            return
        }
        guard let myMbtiType = MBTIType(rawValue: currentUser.mbti) else {
            print("삭제 실패: 내 정보 불러오기 실패")
            return
        }
        likeMeList.remove(at: index)
        reloadTableViewPublisher.onNext(())
      
        let sendData: Like.LikeInfo = Like.LikeInfo(likedUserId: removeData.likedUserId, likeType: .dislike, birth: removeData.birth, nickName: removeData.nickName, mbti: removeData.mbti, imageURL: removeData.imageURL, createdDate: Date().timeIntervalSince1970)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([removeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "sendedlikes": FieldValue.arrayUnion([sendData.asDictionary()])
        ])
        
        let newRecivedData = Like.LikeInfo(likedUserId: currentUser.userId, likeType: .dislike, birth: currentUser.birth, nickName: currentUser.nickName, mbti: myMbtiType, imageURL: currentUser.imageURL, createdDate: Date().timeIntervalSince1970)
        dbRef.collection(Collections.likes.name).document(removeData.likedUserId).updateData([
            "recivedlikes": FieldValue.arrayUnion([newRecivedData.asDictionary()])
        ])
    }
    
    private func likeUser(userId: String) {
        guard let index = likeMeList.firstIndex(where: {
            $0.likedUserId == userId
        }) else {
            return
        }
        guard let likeData: Like.LikeInfo = likeMeList[safe: index] else { return }
        likeMeList.remove(at: index)
        reloadTableViewPublisher.onNext(())
      
        let updateData: Like.LikeInfo = Like.LikeInfo(likedUserId: likeData.likedUserId, likeType: .matching, birth: likeData.birth, nickName: likeData.nickName, mbti: likeData.mbti, imageURL: likeData.imageURL, createdDate: Date().timeIntervalSince1970)
        
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayRemove([likeData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "recivedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])
        dbRef.collection(Collections.likes.name).document(currentUser.userId).updateData([
            "sendedlikes": FieldValue.arrayUnion([updateData.asDictionary()])
        ])

        var tempLike: Like?
        FirestoreService.shared.loadDocument(collectionId: .likes, documentId: likeData.likedUserId, dataType: Like.self) { [weak self] result in
            guard let self = self else { return }
            var updateSendLike: Like.LikeInfo
            switch result {
            case .success(let data):
                tempLike = data
                guard let tempLike = tempLike else {
                    return
                }
                let sendedlikes = tempLike.sendedlikes
                if let sendIndex = sendedlikes?.firstIndex(where: {
                    $0.likedUserId == self.currentUser.userId
                }) {
                    guard let tempSendLike = sendedlikes?[safe: sendIndex] else { return }
                    updateSendLike = Like.LikeInfo(likedUserId: tempSendLike.likedUserId, likeType: .matching, birth: tempSendLike.birth, nickName: tempSendLike.nickName, mbti: tempSendLike.mbti, imageURL: tempSendLike.imageURL, createdDate: Date().timeIntervalSince1970)
                    dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                        "sendedlikes": FieldValue.arrayRemove([tempSendLike.asDictionary()])
                    ])
                } else {
                    guard let tempMbti: MBTIType = MBTIType(rawValue: currentUser.mbti) else { return }
                    updateSendLike = Like.LikeInfo(likedUserId: currentUser.userId, likeType: .matching, birth: currentUser.birth, nickName: currentUser.nickName, mbti: tempMbti, imageURL: currentUser.imageURL, createdDate: Date().timeIntervalSince1970)
                }
              
                dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                    "sendedlikes": FieldValue.arrayUnion([updateSendLike.asDictionary()])
                ])
                dbRef.collection(Collections.likes.name).document(likeData.likedUserId).updateData([
                    "recivedlikes": FieldValue.arrayUnion([updateSendLike.asDictionary()])
                ])
                
                let myNoti = Noti(receiveId: currentUser.userId, sendId: likeData.likedUserId, name: likeData.nickName, birth: likeData.birth, imageUrl: likeData.imageURL, notiType: .matching, mbti: likeData.mbti, createDate: Date().timeIntervalSince1970)
                
                guard let yourMbti = MBTIType(rawValue: currentUser.mbti) else { return }
                let yourNoti = Noti(receiveId: likeData.likedUserId, sendId: currentUser.userId, name: currentUser.nickName, birth: currentUser.birth, imageUrl: currentUser.imageURL, notiType: .matching, mbti: yourMbti, createDate: Date().timeIntervalSince1970)
                FirestoreService.shared.saveDocument(collectionId: .notifications, data: myNoti)
                FirestoreService.shared.saveDocument(collectionId: .notifications, data: yourNoti)               
                let mailModel = MailSendModel()
                let receiverUser = User(id: likeData.likedUserId, mbti: likeData.mbti, phoneNumber: "", gender: .etc, birth: likeData.birth, nickName: likeData.nickName, location: Location(address: "서울시 강남구", latitude: 10, longitude: 10), imageURLs: [likeData.imageURL], createdDate: 10, subInfo: nil, reports: nil, blocks: nil, chuCount: 0, isSubscribe: false)
                mailModel.saveMailData(receiveUser: receiverUser, message: "서로 매칭되었습니다.")
                
                NotificationService.shared.sendNotification(userId: likeData.likedUserId, sendUserName: currentUser.nickName, notiType: .matching)
                NotificationService.shared.sendNotification(userId: currentUser.userId, sendUserName: likeData.nickName, notiType: .matching)
            case .failure(let error):
                print(error)
                return
            }
        }
    }
}
