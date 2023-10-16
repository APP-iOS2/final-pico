import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class EntViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    
    private let randomBoxHeaderView: RandomBoxView = {
        let view = RandomBoxView()
        return view
    }()
    
    private let worldCupViewController = WorldCupViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        makeConstraints()
        configTapGesture()
    }
    
    private func addViews() {
        view.addSubview(randomBoxHeaderView)
        addChild(worldCupViewController)
        view.addSubview(worldCupViewController.view)
        worldCupViewController.didMove(toParent: self)
    }
    
    private func makeConstraints() {
        randomBoxHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(Screen.height * 0.12)
        }
        
        worldCupViewController.view.snp.makeConstraints { make in
            make.top.equalTo(randomBoxHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func configTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedRandomBoxView))
        randomBoxHeaderView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tappedRandomBoxView(_ sender: UITapGestureRecognizer) {
        let randomBoxViewController = RandomBoxViewController()
        self.navigationController?.pushViewController(randomBoxViewController, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}
