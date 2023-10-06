//
//  LoadImageView.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
                
            } else {
                DispatchQueue.main.async {
                    self?.image = UIImage(named: "chu")
                }
            }
        }
    }
    
    func loadImage(url: String, disposeBag: DisposeBag) {
        Observable.just(url)
            .flatMap(loadImageObservable)
            .observe(on: MainScheduler.instance)
            .bind(to: rx.image)
            .disposed(by: disposeBag)
    }
    
    private func loadImageObservable(url: String) -> Observable<UIImage> {
        return Observable.create { emitter in
            guard let url = URL(string: url) else {
                emitter.onNext(UIImage(named: "chu")!)
                emitter.onCompleted()
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    emitter.onNext(UIImage(named: "chu")!)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
            }
            
            task.resume()
            return Disposables.create()
        }
    }
}
