# PICO (Pick & Connect)
![824d1b0b9fc4d055](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/eb4527e5-31a9-4e22-be3d-89d8b7f85339)
  

## 📌 프로젝트 소개
> 2023.09.25 ~ 2023.10.20 (4주간) <br/>
- 나와 맞는 사람을 Pick 하고 나와 잘 맞는 사람들과 Connect
- MBTI(마이어스-브릭스 유형 지표)를 활용한 매칭 시스템을 통해 사용자 간 커뮤니케이션을 지원는 APP
- 소개 영상: https://youtu.be/efr4abi4cTk
- 사용자 메뉴얼: https://github.com/APPSCHOOL3-iOS/final-pico/사용자메뉴얼.pdf


<br/><br/>

  
## 📌 설치 / 실행 방법
1. 아래 파일은 필수 파일이므로 다음 이메일로 파일을 요청해주세요. (rlaalsrl1227@gmail.com)  
```
- GoogleService-Info.plist
- APIKeys.plist
- YOLOv3.mlmodel
```
2. Pico.xcodeproj 파일 실행을 해주세요.
3. Config 폴더에 필수파일을 추가한 뒤 빌드해주세요.



<br/><br/>


## 📌 기능 소개
- 인물사진을 등록하여 회원가입을 하고 가입한 전화번호를 통해서 로그인할 수 있다.
- 사용자를 필터 조건에 맞게 추천해주고 좋아요/싫어요로 평가할 수 있다.
- 사용자의 세부 정보를 확인하고 신고/차단할 수 있다.
- 좋아요/쪽지/매칭의 알림을 받을 수 있다.
- 사용자와 쪽지를 보내고 받을 수 있다.
- 나를 좋아요 한/내가 좋아요 한 사용자를 확인하고 쪽지를 보낼 수 있다.
- 24시간에 한번씩 전체 사용자 중 랜덤 8명으로 이상형 월드컵을 할 수 있다.
- 내 정보를 추가/수정하고 포인트를 구매할 수 있다.
- 알림 허용 설정, 로그아웃, 회원탈퇴를 할 수 있다.

<br/><br/>

## 📌 구현 화면

<table align="center">
  <tr>
    <th><code>로그인/회원가입</code></th>
    <th><code>추천</code></th>
    <th><code>필터</code></th>
    <th><code>쪽지</code></th>
    <th><code>매칭<code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/c402b4d6-050b-46e1-a4af-0981154d535b" alt="로그인/회원가입">
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/977abc0d-d191-401e-9275-a3cae9570507" alt="추천"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/638dc583-a316-4260-9ed1-ef7628058a16" alt="필터"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/74cf1685-a164-487e-830f-81c86cd47105" alt="쪽지"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/7844f42d-72e0-420e-8fef-451bbbd9aeb8" alt="매칭"></td>
  </tr>
</table>

<table align="center">
  <tr>
    <th><code>푸시알림</code></th>
    <th><code>이상형 월드컵</code></th>
    <th><code>랜덤박스</code></th>
    <th><code>마이페이지</code></th>
    <th><code>관리자모드</code></th>
  </tr>
  <tr>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/7d29cd39-08db-4f5a-8f3f-73e992fbe283" alt="푸시알림"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/0e38165c-3af2-44bd-a513-fd7ef5dcbe8d" alt="이상형 월드컵">
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/01dd72ef-36c8-4884-b85f-db40de8f4aa9" alt="랜덤 박스"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/9b523030-f26f-4b17-8c27-157dc081c605" alt="마이페이지"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/ec10939b-c811-4b58-ab04-707eda519e43" alt="관리자모드"></td>
  </tr>
</table>

<br/><br/>


## 📌 개발 도구 및 기술 스택
<img src="https://img.shields.io/badge/swift-F05138?style=for-the-badge&logo=swift&logoColor=white"><img src="https://img.shields.io/badge/xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white"><img src="https://img.shields.io/badge/figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white"><img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"><img src="https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=black"><img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=UIKit&logoColor=white"><img src="https://img.shields.io/badge/firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white">
#### 개발환경
- Swift 5.9, Xcode 15.0.1, iOS 15.0 이상
#### 협업도구
- Figma, Github, Team Notion
#### 기술스택
- UIkit
- SwiftLint, RxSwift, SnapKit, Kingfisher, Lottie
- YoLoV3
- FiresStore, Firebase Storage
- FCM, Naver Cloud SMS API
- DarkMode, VoiceOver


<br/><br/>


## 📌 Folder Convention
```
📦 PICO
+-- 🗂 Config
+-- 🗂 UserDefaults 
+-- 🗂 Extention 
|    +-- 🗂 Namespace
|    +-- 🗂 UI
|    +-- 🗂 Data
+-- 🗂 Service
+-- 🗂 Common
|    +-- 🗂 Constraints
|    +-- 🗂 View
|    +-- 🗂 Transition
+-- 🗂 Utils 
+-- 🗂 Model 
+-- 🗂 Sign 
|    +-- 🗂 SignIn
|    +-- 🗂 SignUp
+-- 🗂 TabBar
+-- 🗂 Home
|    +-- 🗂 Detail 
+-- 🗂 Mail
+-- 🗂 Like
+-- 🗂 Ent
+-- 🗂 MyPage
|    +-- 🗂 RandomBox
|    +-- 🗂 ProfileEdit
|    +-- 🗂 Setting
|    |    +-- 🗂 SettingDetail
|    +-- 🗂 Store
+-- 🗂 Notification
+-- 🗂 Admin
```

<br/><br/>

## 📌 Branch Convention
```mermaid
gitGraph
    commit id: "MAIN"
    branch dev
    checkout dev
    commit id: "Dev"
    branch feature/home
    checkout feature/home
    commit id: "${name}-${taskA}"
    commit id: "${name}-${taskB}"
    checkout dev
    merge feature/home
    commit
    commit
    checkout main
    merge dev
    commit id: "Deploy"
    
```

<br/><br/>


## 📌 팀원소개
<table align="center">
  <tr align="center">
    <th>최하늘</th>
    <th>김민기</th>
    <th>방유빈</th>
    <th>신희권</th>
    <th>양성혜</th>
    <th>오영석</th>
    <th>이제현</th>
    <th>임대진</th>
  </tr>
  <tr align="center">
    <td><img src="https://avatars.githubusercontent.com/u/74815957?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/79855248?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/58802345?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/55128158?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/87599027?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/82360640?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/104299722?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/115560272?v=4" height="80"></td>
  </tr>
  <tr align="center">
    <td><a href="https://github.com/HANLeeeee">@HANLeeeee</a></td>
    <td><a href="https://github.com/minki-kim-git">@minki-kim-git</a></td>
    <td><a href="https://github.com/bangtori">@bangtori</a></td>
    <td><a href="https://github.com/hhh131">@hhh131</a></td>
    <td><a href="https://github.com/seongzzang">@seongzzang</a></td>
    <td><a href="https://github.com/Youngs5">@Youngs5</a></td>
    <td><a href="https://github.com/LJH3904">@LJH3904</a></td>
    <td><a href="https://github.com/DAEJINLIM">@DAEJINLIM</a></td>
  </tr>
</table>
