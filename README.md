# PICO

## 앱 소개(ADS)
- MBTI(마이어스-브릭스 유형 지표)를 활용한 매칭 시스템을 통해 
사용자 간 커뮤니케이션을 지원는 APP


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