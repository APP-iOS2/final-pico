//
//  WorldCupViewModel.swift
//  Pico
//
//  Created by 오영석 on 2023/10/10.
//

import RxSwift
import RxCocoa
import Firebase
import AVFoundation
import Kingfisher
import UIKit

final class WorldCupViewModel {
    
    private let disposeBag = DisposeBag()
    private var audioPlayer: AVAudioPlayer?
    var users: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var selectedIndexPath: IndexPath?
    
    init() {
        loadUsersRx()
    }
    
    func checkStart() -> Bool {
        if users.value.count < 8 {
            return false
        } else {
            return true
        }
    }
    
    func loadUsersRx() {
        let currentUserID = UserDefaultsManager.shared.getUserData().userId
        
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                let filteredData = data.filter { $0.id != currentUserID && $0.id != Bundle.main.testId }
                let shuffledData = filteredData.shuffled()
                let randomUsers = Array(shuffledData.prefix(8))
                
                users.accept(randomUsers)
            }, onError: { error in
                print("오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func configure(cell: WorldCupCollectionViewCell, with user: User) {
        Loading.showLoading()
        
        if let imageURL = URL(string: user.imageURLs.first ?? "") {
            cell.userImage.kf.setImage(with: imageURL) { [weak self] result in
                if case .success = result {
                    cell.mbtiLabel.setMbti(mbti: user.mbti)
//                    cell.userNickname.text = String(user.nickName)
                    cell.userNickname.text = "받은 문서를 찾을 수 없습니다.받은 문서를 찾을 수 없습니다.받은 문서를 찾을 수 없습니다.받은 문서를 찾을 수 없습니다.받은 문서를 찾을 수 없습니다."
                    cell.userAge.text = "\(user.age)세"
                    cell.userInfoStackView.setDataLabelTexts(self?.addDataLabels(user) ?? [])
                    
                    Loading.hideLoading()
                } else {
                    Loading.hideLoading()
                }
            }
        } else {
            Loading.hideLoading()
        }
    }
    
    private func addDataLabels(_ currentUser: User) -> [String] {
        var dataLabelTexts: [String] = []
        
        if let height = currentUser.subInfo?.height {
            dataLabelTexts.append("\(height)")
        } else {
            dataLabelTexts.append(" - ")
        }
        
        if let job = currentUser.subInfo?.job {
            dataLabelTexts.append("\(job)")
        } else {
            dataLabelTexts.append(" - ")
        }
        
        dataLabelTexts.append("\(currentUser.location.address)")
        
        return dataLabelTexts
    }
    
    func animateSelectedCell(collectionView: UICollectionView, indexPath: IndexPath, completion: @escaping () -> Void) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? WorldCupCollectionViewCell else { return }
        
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in 
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            }, completion: { _ in
                completion()
            })
        })
    }
    
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "gameMusic", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
}
