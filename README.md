# PICO (Pick & Connect)
![824d1b0b9fc4d055](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/eb4527e5-31a9-4e22-be3d-89d8b7f85339)

- 나와 맞는 사람을 Pick 하고 나와 잘 맞는 사람들과 Connect
- MBTI(마이어스-브릭스 유형 지표)를 활용한 매칭 시스템을 통해 사용자 간 커뮤니케이션을 지원는 APP

## 📌 앱 소개 영상
https://youtu.be/efr4abi4cTk


## 📌 구동 화면
|로그인/회원가입|사용자 추천|필터|쪽지|매칭|
|:----:|:----:|:-----:|:----:|:----:| 
|![얼굴인식](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/0f27ca36-f452-462b-99c8-ea7dfed70c78)|![홈](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/13b25798-ec1a-4908-9d19-5962de23be2c)|![3 필터](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/82985552-ecbc-4577-a6e4-787b36c9836b)|![쪽지](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/274eacd3-7621-403a-94a9-56a2d7c89e39)|![5 매칭](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/4642e256-8d1d-4f45-8b05-feffa88bf483)|

|푸시알림|이상형 월드컵|랜덤 박스|마이페이지|관리자모드|
|:----:|:----:|:-----:|:----:|:----:| 
|![6 푸시알림](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/bd6c43e1-27c0-4cde-b993-a93567f716be)|![7 이상형 월드컵](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/fccd0480-78d7-4637-a12f-eed2d566c0ae)|![8 랜덤박스](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/bdba4f06-f77f-4cc1-9219-c9f3f0e48e9f)|![9 마이페이지](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/3b6b0897-d5ea-441a-b0ff-46dd522ec07f)|![10 관리자모드](https://github.com/APPSCHOOL3-iOS/final-pico/assets/74815957/f12ca840-d8db-4723-98a2-8add2d8cc155)|



<br/><br/><br/>

  
## 📌 설치 / 실행 방법
1. 아래 파일은 필수 파일이므로 다음 이메일로 파일을 요청해주세요.  
(rlaalsrl1227@gmail.com)  
```
- GoogleService-Info.plist
- APIKeys.plist
- YOLOv3.mlmodel
```
2. Pico.xcodeproj 파일 실행을 해주세요.
3. Config 폴더에 필수파일을 추가한 뒤 빌드해주세요.



<br/><br/><br/>


## 📌 기술스택
<p align="leading">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>


## 📌 개발 도구 및 활용 기술
- 개발 언어 : Swift
- 개발 환경 : Swift5.9 15.0, iPhone SE ~ 15 Pro 호환
- 디자인 툴 : Figma
- 협업 도구 : Github, Team Notion
- 활용한 기술
  - Xcode
  - RxSwift ,Snap Kit
  - YoLoV3
  - FCM, Naver Cloud SMS API
  - FiresStore, Firebase Storage


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
|    |    +-- 🗂 ViewModel
|    +-- 🗂 SignUp
|         +-- 🗂 ViewModel
|         +-- 🗂 SignUpCell
|         +-- 🗂 TermsOfServiceText
+-- 🗂 TabBar
+-- 🗂 Home
|    +-- 🗂 ViewModel 
|    +-- 🗂 Cell
|    +-- 🗂 Detail 
|         +-- 🗂 ViewModel
|         +-- 🗂 Cell
+-- 🗂 Mail
|    +-- 🗂 ViewModel 
|    +-- 🗂 Cell
+-- 🗂 Like
|    +-- 🗂 ViewModel 
|    +-- 🗂 Cell
+-- 🗂 Ent
|    +-- 🗂 ViewModel 
|    +-- 🗂 Cell
+-- 🗂 MyPage
|    +-- 🗂 ViewModel 
|    +-- 🗂 Cell
|    +-- 🗂 RandomBox
|    |    +-- 🗂 ViewModel
|    +-- 🗂 ProfileEdit
|    |    +-- 🗂 ViewModel
|    |    +-- 🗂 Cell
|    +-- 🗂 Setting
|    |    +-- 🗂 SettingDetail
|    |    +-- 🗂 Cell
|    +-- 🗂 Store
+-- 🗂 Notification
|
+-- 🗂 Admin
     +-- 🗂 ViewModel 
     +-- 🗂 Cell 
```


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
|최하늘|김민기|방유빈|신희권|
|:----:|:----:|:-----:|:----:| 
|<img src = "https://avatars.githubusercontent.com/u/74815957?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/79855248?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/58802345?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/55128158?v=4" width="300" height="160">|
|[최하늘 깃허브](https://github.com/HANLeeeee)|[김민기 깃허브](https://github.com/minki-kim-git)|[방유빈 깃허브](https://github.com/bangtori)|[신희권 깃허브](https://github.com/hhh131)|  

|양성혜|오영석|이제현|임대진|
|:----:|:----:|:-----:|:----:|
|<img src = "https://avatars.githubusercontent.com/u/87599027?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/82360640?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/104299722?v=4" width="300" height="160">|<img src = "https://avatars.githubusercontent.com/u/115560272?v=4" width="300" height="160">|
|[양성혜 깃허브](https://github.com/seongzzang)|[오영석 깃허브](https://github.com/Youngs5)|[이제현 깃허브](https://github.com/LJH3904)|[임대진 깃허브](https://github.com/DAEJINLIM)|

---
