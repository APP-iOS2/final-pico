//
//  SignUpTermsOfServiceViewController.swift
//  Pico
//
//  Created by LJh on 2023/09/27.
//

import UIKit
import SnapKit

final class SignUpTermsOfServiceViewController: UIViewController {
    
    private var isCheckedBottom: Bool = false
    private let termsOfServiceTexts: [String] = Te4mp.termsOfServiceTexts
    
    private let progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .picoBetaBlue
        view.progressTintColor = .picoBlue
        view.progress = 0.142 * 7
        view.layer.cornerRadius = Constraint.SignView.progressViewCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private let notifyLabel: UILabel = {
        let label = UILabel()
        label.text = "이용약관에 동의해주세요"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.picoTitleFont
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = CommonButton(type: .custom)
        button.setTitle("완료", for: .normal)
        button.backgroundColor = .picoGray
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .picoAlphaWhite
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configBackButton()
        addSubViews()
        makeConstraints()
        configTableView()
    }
    
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc private func tappedNextButton(_ sender: UIButton) {
        // "완료" 버튼이 눌렸을 때 수행할 동작을 구현하세요.
    }
    
    private func addSubViews() {
        for viewItem in [progressView, notifyLabel, nextButton, tableView] {
            view.addSubview(viewItem)
        }
    }
    
    private func makeConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(Constraint.SignView.progressViewTopPadding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
            make.height.equalTo(8)
        }
        
        notifyLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(Constraint.SignView.padding)
            make.leading.equalTo(Constraint.SignView.padding)
            make.trailing.equalTo(-Constraint.SignView.padding)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(notifyLabel.snp.bottom).offset(Constraint.SignView.contentPadding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(nextButton.snp.top).offset(-Constraint.SignView.padding)
        }
        
        nextButton.snp.makeConstraints { make in
            make.leading.equalTo(notifyLabel.snp.leading)
            make.trailing.equalTo(notifyLabel.snp.trailing)
            make.bottom.equalTo(safeArea).offset(Constraint.SignView.bottomPadding)
            make.height.equalTo(Constraint.Button.commonHeight)
        }
    }
}

// MARK: - UITableViewDataSource
extension SignUpTermsOfServiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return termsOfServiceTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = termsOfServiceTexts[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func updateNextButton(isCheck: Bool) {
        if isCheck {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .picoBlue
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = .picoGray
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isAtBottom = scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        print("before guard Cintax")
        guard !isCheckedBottom else { return }
        print("after guard Cintax")
        if isAtBottom {
            isCheckedBottom = true
            updateNextButton(isCheck: isCheckedBottom)
        } else {
            isCheckedBottom = false
            updateNextButton(isCheck: isCheckedBottom)
        }
    }
}

struct Te4mp {
    static let termsOfServiceTexts: [String] = [
        """
        매일 싸웠던 X와
        헤어지고 술만 마시던 날
        남잔 많다며 위로해 준
        그때부터 였을까
        
        남자친구도 아닌데
        언제부턴가 널 기다렸나 봐
        나 취한 건 아닌데
        네가 정말 좋아서 그랬나 봐
        
        첫 키스에 내 심장은 120 BPM
        세상이 멈춰버린 것 만 같아
        꼭 안아줘 이 노래가 끝나지 않도록
        템포를 올려 너를 사랑할래 이 밤이 새도록
        
        설레는 사람 있다고
        고민 상담하던 너가 미웠어
        사실 내 맘 알면서
        질투 나게 하려고 그런 거야
        
        첫 키스에 내 심장은 120 BPM
        세상이 멈춰버린 것 만 같아
        꼭 안아줘 이 노래가 끝나지 않도록
        템포를 올려 너를 사랑할래 이 밤이 새도록
        
        사실은 나 어제까지 좀 망설였었어
        친구도 아닌 사이가 될까 봐
        손잡아 줘 이 노래가 끝나기 전까지
        템포를 맞춰 너랑 걸어볼래
        
        백 허그에 내 심장은 180 BPM
        세상이 멈춰버린 것 만 같아
        꼭 안아줘 이 노래가 끝나지 않도록
        볼륨을 높여 네게 말해볼래 널 사랑한다고
        """,
        """
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        
        맞바꾸지 못해 다
        아무리 깝쳐봤자 왕 앞에서는 다 망둥이
        싸 구린 rhymes 뱉는 자들 입 다물지 자부심
        좋아봤자 니그들을 다 무시
        사무실 앞으로 와 집합 주기
        사춘기 소년들처럼 까불지
        합주실에서 한요한과 다구리
        바다에 dive 해서 곧바로 sushi
        I keep it raw condom, 경고 무시
        근데 다 민 게 좋아 no bush
        왕 중 왕 shit like George Bush
        Swings 힙 부심 말 안 해 굳이
        다 느껴 내 존재의 부피
        Linchpins가 올해 싹 독점할 때
        다들 찾는 게 돈 no 휴지
        짧은 fuse 멍청인 좇까 내 가사 중 1할 못해도 속담
        과소평가 1위 artist, 다 혀 꺼내 곧 매일 빨릴
        준비하고 있을게 내 친구
        양치 잘해 믿을게 내 친구
        Rapper라면 도전하지 마
        Tyson punch처럼 훅 가니까
        2017년은 내 꺼 you fuckers,
        2년 동안 무덤 안에서 꿈꿨지
        사기꾼 기획사 사장 옷 벗기는 상상을 매일
        내 멘털은 설리
        Hip-hop의 icon은 나라고
        이제 큰 절을 올려봐 각 잡고
        난 다중인격 fashion designer보다
        Style 미친 새끼처럼 막 바꿔
        
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        All my shits like sushi
        All my whips I got sushi
        All my clothes I rock sushi
        All my boys got sushi
        
        What you know about sushi
        Everything you got that ain't sushi
        한국 두시 여긴 열 두시 yeah
        My time zone that's sushi
        I don't wear no swoosh
        Just three stripes on feet
        And my dick ain't free
        Who gon' pay it yo bitch
        
        당시 내 위치는 혼자
        원래 도움을 거절하는 정신병자
        스윙스 said Papi 같이 먹자 돈가스
        Ain't no hilite but yo
        Vision gon be more brightly
        Then I worked on my shit
        While you takin bout shit
        현대차 타는 ballers 넌 꼭두각시
        없는 돈과 옷 얘기만 거듭하지
        언제 희망사항이 됐어 음악이
        
        But I'm sushi mother fucking sushi
        날 것 같아 나는 fly all I hear is sweesh
        Yeah I'm sushi mother fucking sushi
        날 것 같아 나는 fly all I hear is sweesh
        
        All my shits like sushi
        와타시 rap은 아파 like 쯔쯔가무시
        와타시 타치와 기무치 이치방 조센징 just the music
        난떼 아나타? 때려치고 딴 데 알아봐
        지네가 오야붕이래 와캇나이 혼토니 야메떼 쿠다 사이
        간코쿠 오레 나와바리 깝치면 걸어 와사바리
        Are Y'all in the building 와타시
        너네 위를 뛰어넘어 다녀 like 야마카시
        간바레 미나상 우린 맨 위에서 간빠이 하면서 빵빠레
        만만해 J M만 다 까 데모
        우리 삶은 살 맛 밖에 안 나 like 사까시 ey
        
        내 일렉 음악 졸라 스시
        퓨쳐 트랙 물론 스시
        발라드 120 tempo
        Hihat 사시 미질 하면 그것이 스시
        내 모니터 스피커 천칠백 스시
        넌 알아도 못 사지
        내 모니터 스피커 천칠백 스시
        넌 알아도 못 사지 ay
        한번 더 말할게 알아도 못사
        장비에 몇백을 박아도 못싸
        발기부전이야 장가를 못가
        Trap을 못하면 장가를 못가
        Trap을 못하면 장가를 못가
        Trap을 한다면 엄마한테 혼나
        아 몰라 따분한 인생아 좆까
        좆 까고 살아보자 스시
        """,
        """
        Bitch, I'm stylish
        Glock tucked, big T-shirt, Billie Eilish
        Watch on my wrist, but I want that in diamonds
        Niggas talkin' crazy, when I pull up, it'silent
        Mile high, run that shit back, bitch, I'stylish
        Glock tucked, big T-shirt, Billie Eilish
        Watch on my wrist, but I want that in diamonds
        Niggas talkin' crazy, when I pull up, it'silent (ayy, ayy)
        Mile high, fuck a first-class, I'm the pilo(ayy)
        
        Put it in perspective
        Bitch, I got everything I wanted and some extra
        I am not the type for turnin' into a detectiv(no)
        Got two of my own phones, barely even check 'em
        Uber Eats the food, I don't call, I just text it
        Cashed out on bail, my lil' bitch got arrested
        Flexed out my Lexus, no backseats and nbesties (shit)
        I checked it, no guest list, so don't text me
        Ayy, two pistols, .30's in the clip, thesakimbos
        Open hand, smack him in his lip, bitch, I'Kimbo
        You be throwin' cash in the strip
        My lil' bitch suckin' dick for the free
        I got a bitch but a bitch ain't got me
        I know she trip when I dip, so I creep
        These bitches pillow talkin' 'bout me like I'sleep
        But she ain't know this Gen-3 was in mmotherfuckin' tee
        
        Bitch, I'm stylish
        Glock tucked, big T-shirt, Billie Eilish
        Propped up, fuckin' her from the back on aisland
        Heard they talkin' crazy on my name, nothey're silent
        Mile high, run that shit back
        
        Bitch, I'm stylish
        Glock tucked, big T-shirt, Billie Eilish
        Watch on my wrist, but I want that in diamonds
        Niggas talkin' crazy, when I pull up, it'silent
        Mile high, run that shit back, bitch, I'stylish
        Glock tucked, big T-shirt, Billie Eilish
        Watch on my wrist, but I want that in diamonds
        Niggas talkin' crazy, when I pull up, it'silent
        Mile high, fuck a first-class, I'm the pilot
        """
    ]
    
}
