# PICO (Pick & Connect)
![824d1b0b9fc4d055](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/eb4527e5-31a9-4e22-be3d-89d8b7f85339)

- 나와 맞는 사람을 Pick 하고 나와 잘 맞는 사람들과 Connect
- MBTI(마이어스-브릭스 유형 지표)를 활용한 매칭 시스템을 통해 사용자 간 커뮤니케이션을 지원는 APP
  
<br/><br/><br/>

## 📌 앱 소개 영상
https://youtu.be/efr4abi4cTk

<br/><br/><br/>

## 📌 구동 화면

<table align="center">
  <tr>
    <th>로그인/회원가입</th>
    <th>추천</th>
    <th>필터</th>
    <th>쪽지</th>
    <th>매칭</th>
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
    <th>푸시알림</th>
    <th>이상형 월드컵</th>
    <th>랜덥 박스</th>
    <th>마이페이지</th>
    <th>관리자모드</th>
  </tr>
  <tr>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/7d29cd39-08db-4f5a-8f3f-73e992fbe283" alt="푸시알림"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/0e38165c-3af2-44bd-a513-fd7ef5dcbe8d" alt="이상형 월드컵">
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/01dd72ef-36c8-4884-b85f-db40de8f4aa9" alt="랜덤 박스"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/9b523030-f26f-4b17-8c27-157dc081c605" alt="마이페이지"></td>
    <td><img src="https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/ec10939b-c811-4b58-ab04-707eda519e43" alt="관리자모드"></td>
  </tr>
</table>



<br/><br/><br/>

  
## 📌 설치 / 실행 방법
1. 아래 파일은 필수 파일이므로 다음 이메일로 파일을 요청해주세요. (rlaalsrl1227@gmail.com)  
```
- GoogleService-Info.plist
- APIKeys.plist
- YOLOv3.mlmodel
```
2. Pico.xcodeproj 파일 실행을 해주세요.
3. Config 폴더에 필수파일을 추가한 뒤 빌드해주세요.

<br/><br/><br/>

## 📌 사용자 메뉴얼
[사용자메뉴얼.pdf](https://github.com/APPSCHOOL3-iOS/final-pico/files/13216388/default.pdf)



<br/><br/><br/>


## 📌 개발 도구 및 기술 스택
<p align="leading">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>

- 개발 언어 : Swift
- 개발 환경 : Xcode 15.0.1
- 실행 환경 : iOS 15.0 이상
- 디자인 툴 : Figma
- 협업 도구 : Github, Team Notion
- 활용한 기술
  - Xcode
  - SwiftLint, RxSwift, SnapKit, Kingfisher, Lottie
  - YoLoV3
  - FCM, Naver Cloud SMS API
  - FiresStore, Firebase Storage
  - DarkMode, VoiceOver


<br/><br/><br/>


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

<br/><br/><br/>

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

<br/><br/><br/>


## 📌 참여자
<table align="center">
  <tr>
    <th>최하늘</th>
    <th>김민기</th>
    <th>방유빈</th>
    <th>신희권</th>
    <th>양성혜</th>
    <th>오영석</th>
    <th>이제현</th>
    <th>임대진</th>
  </tr>
  <tr>
    <td><img src="https://avatars.githubusercontent.com/u/74815957?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/79855248?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/58802345?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/55128158?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/87599027?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/82360640?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/104299722?v=4" height="80"></td>
    <td><img src="https://avatars.githubusercontent.com/u/115560272?v=4" height="80"></td>
  </tr>
  <tr>
    <td><a href="https://github.com/HANLeeeee">최하늘 깃허브</a></td>
    <td><a href="https://github.com/minki-kim-git">김민기 깃허브</a></td>
    <td><a href="https://github.com/bangtori">방유빈 깃허브</a></td>
    <td><a href="https://github.com/hhh131">신희권 깃허브</a></td>
    <td><a href="https://github.com/seongzzang">양성혜 깃허브</a></td>
    <td><a href="https://github.com/Youngs5">오영석 깃허브</a></td>
    <td><a href="https://github.com/LJH3904">이제현 깃허브</a></td>
    <td><a href="https://github.com/DAEJINLIM">임대진 깃허브</a></td>
  </tr>
</table>
