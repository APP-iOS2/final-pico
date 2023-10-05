//
//  LoadImageView.swift
//  Pico
//
//  Created by 양성혜 on 2023/09/26.
//

import UIKit
import RxSwift

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
            .flatMap(imageLoad)
            .observe(on: MainScheduler.instance)
            .bind(to: rx.image)
            .disposed(by: disposeBag)
    }
    
    private func imageLoad(url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data,
                      let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
