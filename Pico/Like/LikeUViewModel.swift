//
//  LikeUViewViewModel.swift
//  Pico
//
//  Created by 방유빈 on 2023/10/05.
//

import RxSwift
import RxRelay
import UIKit

final class LikeUViewModel {
    var likeUUserList = BehaviorRelay<[Like.LikeInfo]>(value: [])
    var likeUIsEmpty: Observable<Bool> {
        return likeUUserList
            .map { $0.isEmpty }
    }
    var messageButtonTapUser: PublishSubject<User> = PublishSubject()
    var sendViewConnectSubject: PublishSubject<User> = PublishSubject()
    
    private let disposeBag = DisposeBag()
    
    init() {
        FirestoreService.shared.loadDocumentRx(collectionId: .likes, documentId: "조인성", dataType: Like.self)
            .map { like -> [Like.LikeInfo] in
                if let like = like {
                    return like.sendedlikes ?? []
                }
                return []
            }
            .map({ likeInfos in
                return likeInfos.filter { $0.likeType == .like }
            })
            .bind(to: likeUUserList)
            .disposed(by: disposeBag)
        /*
         질문 : 질문 메시지 버튼을 클릭하면 메시지를 보내는 뷰컨트롤러로 이동하게끔하고 싶은데
            맨 처음에 생각한 방법은 뷰모델로 뷰컨트롤러를 전달 받는 방법이였는데
            뷰모델에서 뷰컨트롤러를 전달받는게 이상하다고 느껴져서 sendViewConnectSubject를 뷰모델에 선언을 해두고 뷰컨트롤러에서 구독해서 처리하도록하였습니다
            이렇게 데이터를 전달전달하는 방법이 맞을까요 아니면 뷰모델에 뷰컨트롤러를 끌고 오는게 맞는걸까요??
         */
        messageButtonTapUser.subscribe { user in
            self.sendViewConnectSubject
                .onNext(user)
        }
        .disposed(by: disposeBag)
    }
}
