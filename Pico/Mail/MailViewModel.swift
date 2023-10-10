//
//  MailViewModel.swift
//  Pico
//
//  Created by 양성혜 on 2023/10/05.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseFirestore
import FirebaseFirestoreSwift

enum MailType: String {
    case send = "보낸 쪽지"
    case receive = "받은 쪽지"
}

struct DummyMailUsers {
    let userName: String
    let age: Int
    let mbti: MBTIType
    let mailType: MailType
    let messages: DummyMail
    var title: String {
        return "\(userName), \(age)"
    }
}

struct DummyMail {
    let oppenentName: String
    let oppenentAge: Int
    let imageUrl: String
    let mbti: MBTIType
    let message: String
    let sendedDate: String
    let isReading: Bool
    var oppenentTitle: String {
        return "\(oppenentName), \(oppenentAge)"
    }
}

final class MailViewModel {
    
    var mailList = BehaviorRelay<[DummyMailUsers]>(value: [])
    var mailSendList = BehaviorRelay<[DummyMailUsers]>(value: [])
    var mailRecieveList = BehaviorRelay<[DummyMailUsers]>(value: [])
    
    var mailIsEmpty: Observable<Bool> {
        return mailList
            .map { $0.isEmpty }
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        let mail: [DummyMailUsers] = [
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "스윗라임", oppenentAge: 28, imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .enfp, message: "날이 요즘 너무 쌀쌀해", sendedDate: "09.24", isReading: false)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .send, messages:
                            DummyMail(oppenentName: "스윗라임", oppenentAge: 24, imageUrl: "https://cdn.topstarnews.net/news/photo/201906/636333_333283_461.jpg", mbti: .entj, message: "오늘 날이 참 좋다", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .infj, message: "점순아 반가워 \n점심으로 뭘 먹었니?", sendedDate: "10.24", isReading: false)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .send, messages:
                            DummyMail(oppenentName: "멍때리는댕댕이구름", oppenentAge: 24, imageUrl: "https://image5jvqbd.fmkorea.com/files/attach/new2/20211225/3655109/3113058505/4195166827/e130faca7194985e4f162b3583d52853.jpg", mbti: .istj, message: "일상에 미소를 채우는 더 좋은 한입", sendedDate: "10.24", isReading: true)),
            DummyMailUsers(userName: "오점순", age: 26, mbti: .enfj, mailType: .receive, messages:
                            DummyMail(oppenentName: "마이꾸미", oppenentAge: 24, imageUrl: "https://cdn.newsculture.press/news/photo/202306/526271_651222_532.jpg", mbti: .esfp, message: "한달뒤에 보자", sendedDate: "08.11", isReading: true))
        ]
        mailList.accept(mail)
        divideMail()
    }
    
    private func divideMail() {
        var receiveMails: [DummyMailUsers] = []
        var sendMails: [DummyMailUsers] = []
        
        mailList.value
            .map {
                if $0.mailType == .receive {
                    receiveMails.append($0)
                } else {
                    sendMails.append($0)
                }
            }
        mailSendList.accept(sendMails)
        mailRecieveList.accept(receiveMails)
    }
    
    /// mailtableviewDatasore
    func configMailTableviewDatasource(tableView: UITableView, type: MailType) {
        Loading.showLoading()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        
        if type == .receive {
            mailRecieveList
                .bind(to: tableView.rx
                    .items(cellIdentifier: MailListTableViewCell.reuseIdentifier, cellType: MailListTableViewCell.self)) { _, item, cell in
                        cell.getData(senderUser: item)
                        Loading.hideLoading()
                    }
                    .disposed(by: disposeBag)
        } else {
            mailSendList
                .bind(to: tableView.rx
                    .items(cellIdentifier: MailListTableViewCell.reuseIdentifier, cellType: MailListTableViewCell.self)) { _, item, cell in
                        cell.getData(senderUser: item)
                        Loading.hideLoading()
                    }
                    .disposed(by: disposeBag)
        }
    }
    
    //질문! textView에서 rx 설정하는 아래 코드를 mvvm으로 할 때 여기에 두는 것이 맞나요? 만약 다른 파일을 만들어서 둬야한다면 어떤 식으로 두면 좋을지 모르겠습닏
    /// textview 변경시 불러지는 함수
    func changeTextView(textView: UITextView, label: UILabel) {
        let textViewPlaceHolder = "메시지를 입력하세요"
        
        textView.rx.didBeginEditing
            .bind { _ in
                if textView.text == textViewPlaceHolder {
                    textView.text = nil
                    textView.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        textView.rx.didEndEditing
            .bind { _ in
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    textView.text = textViewPlaceHolder
                    textView.textColor = .picoFontGray
                    self.updateCountLabel(label: label, characterCount: 0)
                }
            }
            .disposed(by: disposeBag)
        
        textView.rx.text
            .orEmpty
            .subscribe(onNext: { changedText in
                let characterCount = changedText.count
                if characterCount <= 300 {
                    self.updateCountLabel(label: label, characterCount: characterCount)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCountLabel(label: UILabel, characterCount: Int) {
        label.text = "\(characterCount)/300"
    }
    
    func saveMailData(sendUserInfo: User, receiveUserInfo: User, message: String) {
        
        let dbRef = Firestore.firestore().collection(Collections.mail.name)
        /*
        firestore.saveDocument(collectionId: .mail,
                               documentId: UUID().uuidString,
                               data: Mail(userId: UUID().uuidString, 
         mailInfo: [Mail.MailInfo(id: UUID().uuidString, sendedUserId: UUID().uuidString, receivedUserId: UUID().uuidString, messages: [Mail.Message(id: UUID().uuidString, message: messageView.text, sendedDate: dateFormetter())])]) )
         */
        
        let messages: [String: Any] = [
                "messageId": UUID().uuidString,
                "message": message,
                "sendedDate": dateFormetter()
            ]
        
        //보내는 사람
        dbRef.document(sendUserInfo.id).setData(
            [
                "userId": sendUserInfo.id,
                "mailInfo": [
                    "sendedUserId": sendUserInfo.id,
                    "receivedUserId": receiveUserInfo.id,
                    "messages": FieldValue.arrayUnion([messages])
                ]
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
        
        //받는 사람
        dbRef.document(receiveUserInfo.id).setData(
            [ 
                "userId": receiveUserInfo.id,
                "mailInfo": [
                  "sendedUserId": sendUserInfo.id,
                  "receivedUserId": receiveUserInfo.id,
                  "messages": FieldValue.arrayUnion([messages])
                ]
            ], merge: true) { error in
                if let error = error {
                    print("평가 업데이트 에러: \(error)")
                } else {
                    print("평가 업데이트 성공")
                }
            }
    }
    
    private func dateFormetter() -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var currentDateString = formatter.string(from: Date())
        return currentDateString
    }
}
