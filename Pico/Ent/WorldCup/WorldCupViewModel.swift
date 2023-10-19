//
//  WorldCupViewModel.swift
//  Pico
//
//  Created by 오영석 on 2023/10/10.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase
import AVFoundation

final class WorldCupViewModel {
    
    private let disposeBag = DisposeBag()
    private var audioPlayer: AVAudioPlayer?
    var users: BehaviorRelay<[User]> = BehaviorRelay(value: [])
    var selectedIndexPath: IndexPath?
    
    init() {
        loadUsersRx()
    }
    
    func loadUsersRx() {
        FirestoreService.shared.loadDocumentRx(collectionId: .users, dataType: User.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                
                let shuffledData = data.shuffled()
                
                let randomUsers = Array(shuffledData.prefix(8))
                
                self.users.accept(randomUsers)
            }, onError: { error in
                print("오류: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func configure(cell: WorldCupCollectionViewCell, with user: User) {
        cell.mbtiLabel.setMbti(mbti: user.mbti)
        cell.userNickname.text = String(user.nickName)
        cell.userAge.text = "\(user.age)세"
        
        let dataLabelTexts = addDataLabels(user)
        cell.userInfoStackView.setDataLabelTexts(dataLabelTexts)
        
        if let imageURL = URL(string: user.imageURLs.first ?? "") {
            cell.userImage.load(url: imageURL)
        }
    }
    
    private func addDataLabels(_ currentUser: User) -> [String] {
        var dataLabelTexts: [String] = []
        
        if let height = currentUser.subInfo?.height {
            dataLabelTexts.append("\(height)")
        } else {
            dataLabelTexts.append("")
        }
        
        if let job = currentUser.subInfo?.job {
            dataLabelTexts.append("\(job)")
        } else {
            dataLabelTexts.append("")
        }
        
        dataLabelTexts.append("\(currentUser.location.address)")
        
        return dataLabelTexts
    }
    
    func animateSelectedCell(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? WorldCupCollectionViewCell else {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            selectedCell.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                selectedCell.transform = .identity
            }
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
