# PICO (Pick & Connect)
![pico](https://github.com/APPSCHOOL3-iOS/final-pico/assets/115560272/37edf834-f1f8-41d9-a375-1176e28dad07)
- 나와 맞는 사람을 Pick 하고 나와 잘 맞는 사람들과 Connect 

## 앱 소개(ADS)
- MBTI(마이어스-브릭스 유형 지표)를 활용한 매칭 시스템을 통해 
사용자 간 커뮤니케이션을 지원는 APP

## 기술스택
<p align="leading">
  <img src="https://img.shields.io/badge/Swift-F05138?style=for-the-badge&logo=Swift&logoColor=white"/>
    <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=uikit&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=Firebase&logoColor=white"/>
</p>

## 개발 도구 및 활용 기술
- 개발 언어 : Swift
- 개발 환경 : Swift5.9 15.0, iPhone SE ~ 15 Pro 호환
- 디자인 툴 : Figma
- 협업 도구 : Github, Team Notion
- 활용한 기술
  - Xcode
  - RxSwift
  - YoLoV3
  - FCM, Firebase function
  - FiresStore, Firebase Storage
  - Naver Cloud SMS API
  - CoreData
  
## 설치 / 실행 방법
1. 아래 파일은 필수 파일이므로 다음 이메일로 파일을 요청해주세요.  
(temp@gmail.com)  
```
- APIKeys.plist
- GoogleService-Info.plist
- YOLOv3.mlmodel
```
2. 
3.

## Branch Convention
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
## 팀원

<div style="display: flex; overflow-x: auto;">

<!-- 최하늘 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>최하늘</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="arim_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/HANLeeeee">최하늘 깃허브</a></p>
  </div>
  
<!-- 김민기 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>김민기</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="john_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/minki-kim-git">김민기 깃허브</a></p>
  </div>

<!-- 방유빈 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>방유빈</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/bangtori">방유빈 깃허브</a></p>
  </div>
<!-- 신희권 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>신희권</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/hhh131">신희권 깃허브</a></p>
  </div>

  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>양성혜</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/seongzzang">양성혜 깃허브</a></p>
  </div>

<!-- 오영석 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>오영석</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/Youngs5">오영석 깃허브</a></p>
  </div>

<!-- 이제현 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>이제현</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/LJH3904">이제현 깃허브</a></p>
  </div>

<!-- 임대진 -->
  <div style="flex: 0 0 150px; border: 1px solid #ccc; text-align: center;">
    <h3>임대진</h3>
    <div style="border-top: 1px solid #ccc;"></div>
    <img src="jane_photo.jpg">
    <div style="border-top: 1px solid #ccc;"></div>
    <p><a href="https://github.com/DAEJINLIM">임대진 깃허브</a></p>
  </div>

</div>